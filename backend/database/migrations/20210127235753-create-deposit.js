'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Deposits', {
      id: {
        allowNull: false,
        autoIncrement: false,
        primaryKey: true,
        type: Sequelize.UUID
      },
      jobber_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobbers', key: 'id'}
      },
      amount: {
        type: Sequelize.DECIMAL(10,2)
      },
      status: {
        type: Sequelize.ENUM,
        values: ['queue','pending','success','failed']
      },
      ref_code: {
        type: Sequelize.STRING
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
    await queryInterface.dropTable('Deposits');
  }
};
