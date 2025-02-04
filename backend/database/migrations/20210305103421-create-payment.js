'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Payments', {
      id: {
        allowNull: false,
        autoIncrement: false,
        primaryKey: true,
        type: Sequelize.UUID
      },
      user_id: {
        type: Sequelize.UUID,
        references: {model: 'Users',key: 'id'}
      },
      request_id: {
        type: Sequelize.UUID,
        references: {model: 'Requests', key: 'id'}
      },
      authority: {
        type: Sequelize.STRING
      },
      use_wallet: {
        type: Sequelize.BOOLEAN
      },
      total_amount: {
        type: Sequelize.DECIMAL(10,2)
      },
      payable_amount: {
        type: Sequelize.DECIMAL(10,2)
      },
      status: {
        type: Sequelize.ENUM,
        values: ['created','success','wallet','failed'],
        defaultValue: 'created'
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
    await queryInterface.dropTable('Payments');
  }
};
