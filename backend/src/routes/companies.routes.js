const express = require('express');
const CompanyController = require('../controllers/companies.controller');

const router = express.Router();

// Get all companies
router.get('/', CompanyController.getAllCompanies);

// Get company details
router.get('/:companyId', CompanyController.getCompanyDetails);

// Get company by slug
router.get('/slug/:slug', CompanyController.getCompanyBySlug);

// Get company ratings
router.get('/:companyId/ratings', CompanyController.getCompanyRatings);

// Get company schedules
router.get('/:slug/schedules', CompanyController.getCompanySchedules);

module.exports = router;
