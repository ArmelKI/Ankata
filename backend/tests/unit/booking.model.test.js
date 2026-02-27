const BookingModel = require('../../src/models/Booking');
const pool = require('../../src/database/connection');

// Mock the database pool
jest.mock('../../src/database/connection', () => ({
  query: jest.fn(),
}));

describe('BookingModel', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findById', () => {
    it('should return a booking if found', async () => {
      const mockBooking = { id: 1, booking_code: 'TEST123' };
      pool.query.mockResolvedValue({ rows: [mockBooking] });

      const result = await BookingModel.findById(1);

      expect(pool.query).toHaveBeenCalledWith(
        'SELECT * FROM bookings WHERE id = $1',
        [1]
      );
      expect(result).toEqual(mockBooking);
    });

    it('should return null if booking not found', async () => {
      pool.query.mockResolvedValue({ rows: [] });

      const result = await BookingModel.findById(999);

      expect(result).toBeNull();
    });
  });

  describe('getCancelledBookings', () => {
    it('should return cancelled bookings for a user', async () => {
      const mockBookings = [
        { id: 1, booking_status: 'CANCELLED' },
        { id: 2, booking_status: 'CANCELLED' },
      ];
      pool.query.mockResolvedValue({ rows: mockBookings });

      const result = await BookingModel.getCancelledBookings('user123');

      expect(pool.query).toHaveBeenCalled();
      expect(result).toEqual(mockBookings);
      expect(pool.query.mock.calls[0][1]).toEqual(['user123']);
    });
  });
});
