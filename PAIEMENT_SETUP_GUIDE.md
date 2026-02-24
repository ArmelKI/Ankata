# 💳 SYSTÈME DE PAIEMENT COMPLET - ANKATA

## Vue d'ensemble

**Objectif**: Permettre paiement sécurisé avec 3 méthodes principales au Burkina Faso

**Méthodes de paiement**:
1. 🟠 **Orange Money** (70% du marché)
2. 🟡 **MTN Mobile Money** (20% du marché)
3. 💳 **Cartes bancaires** via Stripe/Wave (10% du marché)

**Commission recommandée**: 2-3% par transaction

---

## PARTIE 1: Orange Money (PRIORITÉ #1)

### 1.1 Inscription Orange Money API

1. **Contacter Orange Burkina Faso**
   - Email: [digitalservices@orange.bf](mailto:digitalservices@orange.bf)
   - Téléphone: +226 25 30 02 00
   - Demander: "Intégration API Orange Money pour application mobile"

2. **Documents requis**:
   - IFU (Identifiant Fiscal Unique)
   - Registre de commerce
   - Pièce d'identité gérant
   - Description application
   - Volume estimé transactions/mois

3. **Obtenir credentials**:
   - `client_id`
   - `client_secret`
   - `merchant_key`
   - URL API prod: `https://api.orange.com/orange-money-bf/`

### 1.2 Flow Orange Money

```
1. User clique "Payer avec Orange Money"
2. App envoie demande paiement au backend
3. Backend appelle API Orange Money
4. User reçoit prompt USSD sur téléphone
5. User confirme avec PIN Orange Money
6. Backend reçoit callback confirmation
7. App affiche succès
```

### 1.3 Implémentation Backend (Node.js)

```javascript
// backend/src/services/orangeMoney.js

const axios = require('axios');

class OrangeMoneyService {
  constructor() {
    this.baseURL = process.env.ORANGE_MONEY_API_URL;
    this.clientId = process.env.ORANGE_MONEY_CLIENT_ID;
    this.clientSecret = process.env.ORANGE_MONEY_CLIENT_SECRET;
    this.merchantKey = process.env.ORANGE_MONEY_MERCHANT_KEY;
    this.accessToken = null;
  }

  // Obtenir token d'authentification
  async getAccessToken() {
    if (this.accessToken) return this.accessToken;

    try {
      const response = await axios.post(
        `${this.baseURL}/oauth/v2/token`,
        {
          grant_type: 'client_credentials',
        },
        {
          auth: {
            username: this.clientId,
            password: this.clientSecret,
          },
        }
      );

      this.accessToken = response.data.access_token;
      
      // Token expire après 1h, reset
      setTimeout(() => {
        this.accessToken = null;
      }, 3500000); // 58 min

      return this.accessToken;
    } catch (error) {
      console.error('Orange Money auth error:', error);
      throw new Error('Authentication failed');
    }
  }

  // Initier paiement
  async initiatePayment({
    amount,
    phoneNumber,
    orderId,
    description,
  }) {
    try {
      const token = await this.getAccessToken();

      const response = await axios.post(
        `${this.baseURL}/omcoreapis/1.0.2/bf/webpayment`,
        {
          merchant_key: this.merchantKey,
          currency: 'XOF',
          order_id: orderId,
          amount: amount,
          return_url: `https://ankata.app/payment/callback`,
          cancel_url: `https://ankata.app/payment/cancel`,
          notif_url: `https://api.ankata.app/webhooks/orange-money`,
          lang: 'fr',
          reference: `ANK-${orderId}`,
          subscriber_msisdn: phoneNumber.replace('+', ''),
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        }
      );

      return {
        success: true,
        paymentToken: response.data.payment_token,
        paymentUrl: response.data.payment_url,
        orderId: orderId,
      };
    } catch (error) {
      console.error('Orange Money payment error:', error.response?.data);
      throw error;
    }
  }

  // Vérifier statut transaction
  async checkPaymentStatus(paymentToken) {
    try {
      const token = await this.getAccessToken();

      const response = await axios.get(
        `${this.baseURL}/omcoreapis/1.0.2/bf/paymentstatus/${paymentToken}`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      return {
        status: response.data.status, // SUCCESS, PENDING, FAILED
        amount: response.data.amount,
        orderId: response.data.order_id,
      };
    } catch (error) {
      console.error('Payment status error:', error);
      throw error;
    }
  }
}

module.exports = new OrangeMoneyService();
```

### 1.4 Route Backend

```javascript
// backend/src/routes/payment.js

const express = require('express');
const router = express.Router();
const orangeMoney = require('../services/orangeMoney');
const { authenticateToken } = require('../middleware/auth');

// Initier paiement
router.post('/initiate', authenticateToken, async (req, res) => {
  try {
    const { amount, phoneNumber, bookingId } = req.body;
    const userId = req.user.id;

    // Créer commande
    const orderId = `BK-${bookingId}-${Date.now()}`;

    // Initier paiement Orange Money
    const payment = await orangeMoney.initiatePayment({
      amount,
      phoneNumber,
      orderId,
      description: `Réservation Ankata #${bookingId}`,
    });

    // Sauvegarder transaction en DB
    await db.query(
      `INSERT INTO payments (user_id, booking_id, order_id, payment_token, amount, status, payment_method)
       VALUES ($1, $2, $3, $4, $5, 'PENDING', 'ORANGE_MONEY')`,
      [userId, bookingId, orderId, payment.paymentToken, amount]
    );

    res.json({
      success: true,
      paymentUrl: payment.paymentUrl,
      orderId: orderId,
      message: 'Confirme le paiement sur ton téléphone',
    });
  } catch (error) {
    console.error('Payment initiation error:', error);
    res.status(500).json({ error: 'Payment failed' });
  }
});

// Webhook Orange Money (callback)
router.post('/webhooks/orange-money', async (req, res) => {
  try {
    const { order_id, status, payment_token } = req.body;

    // Vérifier signature (sécurité)
    // TODO: Valider signature Orange Money

    // Mettre à jour statut
    await db.query(
      `UPDATE payments 
       SET status = $1, updated_at = NOW()
       WHERE order_id = $2`,
      [status, order_id]
    );

    if (status === 'SUCCESS') {
      // Confirmer réservation
      const payment = await db.query(
        `SELECT booking_id, user_id FROM payments WHERE order_id = $1`,
        [order_id]
      );

      if (payment.rows.length > 0) {
        await db.query(
          `UPDATE bookings SET status = 'CONFIRMED', payment_status = 'PAID' WHERE id = $1`,
          [payment.rows[0].booking_id]
        );

        // Envoyer notification utilisateur
        // TODO: Firebase notification
      }
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
});

// Vérifier statut paiement
router.get('/status/:orderId', authenticateToken, async (req, res) => {
  try {
    const { orderId } = req.params;

    const result = await db.query(
      `SELECT * FROM payments WHERE order_id = $1 AND user_id = $2`,
      [orderId, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    const payment = result.rows[0];

    // Si pending, vérifier avec Orange Money
    if (payment.status === 'PENDING') {
      const status = await orangeMoney.checkPaymentStatus(payment.payment_token);
      
      if (status.status !== 'PENDING') {
        await db.query(
          `UPDATE payments SET status = $1 WHERE order_id = $2`,
          [status.status, orderId]
        );
        payment.status = status.status;
      }
    }

    res.json({
      orderId: payment.order_id,
      status: payment.status,
      amount: payment.amount,
    });
  } catch (error) {
    console.error('Status check error:', error);
    res.status(500).json({ error: 'Status check failed' });
  }
});

module.exports = router;
```

---

## PARTIE 2: MTN Mobile Money

### 2.1 Inscription MTN

1. **Contacter MTN Burkina Faso**
   - Email: [momo@mtn.bf](mailto:momo@mtn.bf)
   - Demander: "Intégration API MTN Mobile Money"

2. **Documents requis**: (similaire Orange)

3. **Credentials**:
   - `api_user`
   - `api_key`
   - `subscription_key`

### 2.2 Implémentation (Similaire Orange)

```javascript
// backend/src/services/mtnMoney.js

const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

class MTNMoneyService {
  constructor() {
    this.baseURL = process.env.MTN_MOMO_API_URL || 'https://proxy.momoapi.mtn.com';
    this.subscriptionKey = process.env.MTN_SUBSCRIPTION_KEY;
    this.apiUser = process.env.MTN_API_USER;
    this.apiKey = process.env.MTN_API_KEY;
  }

  async requestToPay({ amount, phoneNumber, orderId, description }) {
    try {
      const referenceId = uuidv4();

      await axios.post(
        `${this.baseURL}/collection/v1_0/requesttopay`,
        {
          amount: amount.toString(),
          currency: 'XOF',
          externalId: orderId,
          payer: {
            partyIdType: 'MSISDN',
            partyId: phoneNumber.replace('+226', ''),
          },
          payerMessage: description,
          payeeNote: `Ankata - ${orderId}`,
        },
        {
          headers: {
            'X-Reference-Id': referenceId,
            'X-Target-Environment': 'mtnbf',
            'Ocp-Apim-Subscription-Key': this.subscriptionKey,
            Authorization: `Bearer ${await this.getAccessToken()}`,
          },
        }
      );

      return {
        success: true,
        referenceId,
        orderId,
      };
    } catch (error) {
      console.error('MTN request to pay error:', error.response?.data);
      throw error;
    }
  }

  async getAccessToken() {
    // Implémentation OAuth similaire Orange
    // ...
  }

  async checkPaymentStatus(referenceId) {
    // Vérifier statut transaction
    // ...
  }
}

module.exports = new MTNMoneyService();
```

---

## PARTIE 3: Cartes Bancaires (Stripe)

### 3.1 Configuration Stripe

1. **Créer compte Stripe**: [stripe.com](https://stripe.com)
2. **Obtenir clés**:
   - Publishable key (public)
   - Secret key (privé)

### 3.2 Ajouter Package Flutter

```yaml
# pubspec.yaml
dependencies:
  flutter_stripe: ^10.1.0
```

### 3.3 Implémentation Flutter

```dart
// mobile/lib/services/stripe_service.dart

import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static Future<void> initialize() async {
    Stripe.publishableKey = 'pk_test_...';
    await Stripe.instance.applySettings();
  }

  static Future<bool> processPayment({
    required int amount,
    required String bookingId,
  }) async {
    try {
      // 1. Créer PaymentIntent sur backend
      final paymentIntent = await _createPaymentIntent(amount, bookingId);
      
      // 2. Initialiser payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Ankata',
          style: ThemeMode.light,
        ),
      );
      
      // 3. Afficher payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      // 4. Paiement réussi
      return true;
    } catch (e) {
      print('Payment error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> _createPaymentIntent(
    int amount,
    String bookingId,
  ) async {
    // Appeler backend pour créer PaymentIntent
    final response = await http.post(
      Uri.parse('https://api.ankata.app/payments/create-intent'),
      body: {
        'amount': amount.toString(),
        'booking_id': bookingId,
      },
    );
    return jsonDecode(response.body);
  }
}
```

### 3.4 Backend Stripe

```javascript
// backend/src/services/stripe.js

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

async function createPaymentIntent(amount, bookingId) {
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount, // en centimes
    currency: 'xof',
    metadata: {
      booking_id: bookingId,
    },
  });

  return {
    client_secret: paymentIntent.client_secret,
  };
}

module.exports = { createPaymentIntent };
```

---

## PARTIE 4: Implémentation UI Flutter

### 4.1 Écran de Sélection de Paiement

```dart
// mobile/lib/screens/payment/payment_method_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/animated_button.dart';
import '../../utils/haptic_helper.dart';

class PaymentMethodScreen extends StatefulWidget {
  final int amount;
  final String bookingId;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    required this.bookingId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'ORANGE_MONEY';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir le mode de paiement'),
      ),
      body: Column(
        children: [
          // Amount display
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Montant à payer',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.amount} FCFA',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          // Payment methods
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PaymentMethodCard(
                  icon: '🟠',
                  title: 'Orange Money',
                  subtitle: 'Paiement instantané',
                  value: 'ORANGE_MONEY',
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    HapticHelper.lightImpact();
                    setState(() => _selectedMethod = value!);
                  },
                ),
                const SizedBox(height: 12),
                _PaymentMethodCard(
                  icon: '🟡',
                  title: 'MTN Mobile Money',
                  subtitle: 'Paiement instantané',
                  value: 'MTN_MONEY',
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    HapticHelper.lightImpact();
                    setState(() => _selectedMethod = value!);
                  },
                ),
                const SizedBox(height: 12),
                _PaymentMethodCard(
                  icon: '💳',
                  title: 'Carte bancaire',
                  subtitle: 'Visa, Mastercard',
                  value: 'CARD',
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    HapticHelper.lightImpact();
                    setState(() => _selectedMethod = value!);
                  },
                ),
              ],
            ),
          ),
          
          // Pay button
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedButton(
              text: _isProcessing ? 'Traitement...' : 'Payer',
              isLoading: _isProcessing,
              onPressed: _processPayment,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // TODO: Appeler API selon méthode choisie
      if (_selectedMethod == 'ORANGE_MONEY') {
        // await orangeMoneyPayment();
      } else if (_selectedMethod == 'MTN_MONEY') {
        // await mtnMoneyPayment();
      } else {
        // await cardPayment();
      }

      // Success
      if (mounted) {
        HapticHelper.success();
        Navigator.pushReplacementNamed(context, '/payment-success');
      }
    } catch (e) {
      HapticHelper.error();
      // Show error
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?>? onChanged;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged?.call(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## PARTIE 5: Configuration & Variables

### 5.1 Backend .env

```bash
# Orange Money
ORANGE_MONEY_API_URL=https://api.orange.com/orange-money-bf/
ORANGE_MONEY_CLIENT_ID=your_client_id
ORANGE_MONEY_CLIENT_SECRET=your_client_secret
ORANGE_MONEY_MERCHANT_KEY=your_merchant_key

# MTN Mobile Money
MTN_MOMO_API_URL=https://proxy.momoapi.mtn.com
MTN_SUBSCRIPTION_KEY=your_subscription_key
MTN_API_USER=your_api_user
MTN_API_KEY=your_api_key

# Stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

---

## COÛTS & REVENUS

### Frais de transaction

| Méthode | Frais Provider | Commission Ankata | Net |
|---------|---------------|------------------|-----|
| Orange Money | 1% | 2% | **Marge 1%** |
| MTN Money | 1% | 2% | **Marge 1%** |
| Carte (Stripe) | 2.9% + 0.30€ | 3% | **Marge 0.1%** |

### Exemple: Réservation 5000 FCFA

- **Orange Money**: 
  - Frais Orange: 50 F
  - Commission Ankata: 100 F
  - **Profit: 50 FCFA par transaction**

- **MTN**:  Similaire

- **Volume estimé**: 1000 transactions/mois = **50,000 FCFA profit**

---

## Checklist Implémentation

- [ ] Contacter Orange Money Burkina Faso
- [ ] Obtenir credentials Orange
- [ ] Contacter MTN Mobile Money
- [ ] Obtenir credentials MTN
- [ ] Créer compte Stripe
- [ ] Implémenter services backend
- [ ] Tester en sandbox
- [ ] Implémenter UI Flutter
- [ ] Tester paiements end-to-end
- [ ] Déployer en production

**Temps estimé**: 3-4 jours si credentials disponibles immédiatement

---

## Prochaines Étapes

1. **Commencer par Orange Money** (70% marché)
2. MTN Money ensuite
3. Stripe en dernier (moins urgent)

**Sans paiement = Zéro revenu!** C'est la priorité #1 absolue.

