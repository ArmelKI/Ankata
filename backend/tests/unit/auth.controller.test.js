const request = require('supertest');
const app = require('../../src/index');
const UserModel = require('../../src/models/User');
const bcrypt = require('bcryptjs');

// Mock UserModel
jest.mock('../../src/models/User');
// Mock bcryptjs
jest.mock('bcryptjs');
// Mock Firebase Admin
jest.mock('../../src/config/firebase', () => ({
  auth: () => ({
    verifyIdToken: jest.fn(),
  }),
}));
// Mock Supabase
jest.mock('../../src/config/supabase', () => ({
  storage: {
    from: jest.fn().mockReturnThis(),
    createSignedUrl: jest.fn(),
  },
}));

describe('AuthController', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /api/auth/login', () => {
    it('should login successfully with valid credentials', async () => {
      const mockUser = {
        id: 1,
        phone_number: '22612345678',
        password_hash: 'hashed_password',
        first_name: 'Test',
        last_name: 'User',
      };

      UserModel.findByPhone.mockResolvedValue(mockUser);
      bcrypt.compare.mockResolvedValue(true);

      const response = await request(app)
        .post('/api/auth/login')
        .send({ phoneNumber: '70000000', password: 'password123' });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body.user.firstName).toBe('Test');
    });

    it('should return 400 for invalid credentials', async () => {
      UserModel.findByPhone.mockResolvedValue(null);

      const response = await request(app)
        .post('/api/auth/login')
        .send({ phoneNumber: '70000000', password: 'wrong_password' });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Invalid credentials.');
    });
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      UserModel.findByPhone.mockResolvedValue(null);
      bcrypt.genSalt.mockResolvedValue('salt');
      bcrypt.hash.mockResolvedValue('hashed');
      UserModel.create.mockResolvedValue({
        id: 1,
        phone_number: '22670000000',
        first_name: 'New',
        last_name: 'User',
      });

      const response = await request(app)
        .post('/api/auth/register')
        .send({
          phoneNumber: '70000000',
          firstName: 'New',
          lastName: 'User',
          password: 'password123',
          securityQ1: 'What is your favorite color?',
          securityA1: 'Blue',
          securityQ2: 'What is your city?',
          securityA2: 'Ouaga',
        });

      expect(response.status).toBe(201);
      expect(response.body.message).toBe('Registered successfully');
      expect(UserModel.create).toHaveBeenCalled();
    });
  });
});
