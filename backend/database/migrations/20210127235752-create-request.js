'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Requests', {
      id: {
        allowNull: false,
        autoIncrement: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      jobber_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobbers', key: 'id'}
      },
      user_id: {
        type: Sequelize.UUID,
        references: {model: 'Users', key: 'id'}
      },
      job_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobs', key: 'id'}
      },
      deposit_id: {
        type: Sequelize.UUID,
        references: {model: 'Deposits', key: 'id'}
      },
      price: {
        type: Sequelize.DECIMAL(10,2)
      },
      status: {
        type: 'public."request_status"'
      },
      location: {
        type: 'earth'
      },
      address: {
        type: Sequelize.STRING
      },
      paid: {
        type: Sequelize.BOOLEAN
      },
      arrival_time: {
        type: Sequelize.DECIMAL(3,0)
      },
      time_base: {
        type: Sequelize.BOOLEAN
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Requests');
  }
};
