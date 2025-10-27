const request = require('supertest');
const path = require('path');
const fs = require('fs');
const app = require('../server');

describe('CSE Motors Server', () => {
  describe('GET /', () => {
    it('should return 200 and HTML', async () => {
      const response = await request(app)
        .get('/')
        .expect('Content-Type', /html/)
        .expect(200);
      
      expect(response.text).toContain('CSE Motors');
      expect(response.text).toContain('Drive the future');
    });
  });

  describe('POST /inquiry', () => {
    const validInquiry = {
      name: 'Test User',
      email: 'test@example.com',
      message: 'Test message'
    };

    it('should accept valid inquiry', async () => {
      const response = await request(app)
        .post('/inquiry')
        .send(validInquiry)
        .expect(200);
      
      expect(response.text).toContain('Thanks!');
    });

    it('should reject invalid email', async () => {
      const response = await request(app)
        .post('/inquiry')
        .send({ ...validInquiry, email: 'invalid' })
        .expect(400);
      
      expect(response.text).toContain('valid email');
    });
  });
});