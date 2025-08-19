# Specialty Dining and Culinary Experiences Smart Contract System

A comprehensive blockchain-based system for managing specialty dining experiences, chef certifications, and culinary event coordination built on the Stacks blockchain using Clarity smart contracts.

## System Overview

This system consists of five interconnected smart contracts that manage different aspects of the culinary experience ecosystem:

### 1. Chef Certification Contract (`chef-certification.clar`)
- Manages chef credentials and certification levels
- Tracks specializations and experience ratings
- Handles certification renewals and upgrades
- Provides verification mechanisms for dining establishments

### 2. Culinary Events Management Contract (`culinary-events.clar`)
- Coordinates culinary events and dining experiences
- Manages event scheduling and capacity
- Handles booking and reservation systems
- Tracks event success metrics

### 3. Ingredient Sourcing and Dietary Contract (`ingredient-dietary.clar`)
- Manages ingredient sourcing and supplier relationships
- Tracks dietary restrictions and allergen information
- Provides transparency in ingredient origins
- Handles seasonal availability and pricing

### 4. Guest Feedback and Quality Assurance Contract (`guest-feedback.clar`)
- Collects and manages guest reviews and ratings
- Implements quality assurance mechanisms
- Tracks satisfaction metrics across experiences
- Provides reputation scoring for chefs and venues

### 5. Supplier Relationships Contract (`supplier-relationships.clar`)
- Manages local supplier partnerships
- Tracks supplier reliability and quality metrics
- Handles contract negotiations and agreements
- Supports seasonal menu planning coordination

## Key Features

- **Transparent Pricing**: All pricing information is stored on-chain for complete transparency
- **Experience Customization**: Flexible system for creating personalized dining experiences
- **Quality Assurance**: Built-in feedback and rating systems ensure high standards
- **Local Sourcing**: Strong support for local supplier relationships and seasonal ingredients
- **Certification Tracking**: Comprehensive chef certification and skill verification

## Technical Architecture

### Data Types
- **Chef Profile**: Certification level, specializations, experience points
- **Culinary Event**: Event details, capacity, pricing, requirements
- **Ingredient**: Source information, dietary flags, seasonal availability
- **Guest Review**: Rating, comments, verification status
- **Supplier**: Contact info, reliability score, product categories

### Core Functions
- Chef registration and certification management
- Event creation and booking systems
- Ingredient sourcing and dietary accommodation
- Guest feedback collection and analysis
- Supplier relationship management

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing
- Node.js and npm for running tests

### Installation
\`\`\`bash
# Clone the repository
git clone <repository-url>
cd culinary-clarity-system

# Install dependencies
npm install

# Run Clarinet checks
clarinet check

# Run tests
npm test
\`\`\`

### Deployment
\`\`\`bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
\`\`\`

## Contract Interactions

### Chef Certification
```clarity
;; Register a new chef
(contract-call? .chef-certification register-chef "Chef Name" u3 (list "Italian" "Molecular"))

;; Verify chef certification
(contract-call? .chef-certification get-chef-info 'SP1234...)
