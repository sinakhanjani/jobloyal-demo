'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Comments', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      comment: {
        type: Sequelize.TEXT
      },
      rate: {
        type: Sequelize.DECIMAL(1,0)
      },
      jobber_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobbers', key: 'id'}
      },
      service_id: {
        type: Sequelize.UUID,
        references: {model: 'Services', key: 'id'}
      },
      job_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobs', key: 'id'}
      },
      request_id: {
        type: Sequelize.UUID,
        unique: true,
        references: {model: 'Requests', key: 'id'}
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Comments');
  }
};
