'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('RequestServices', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      request_id: {
        type: Sequelize.UUID,
        references: {model: 'Requests',key: 'id'}
      },
      service_id: {
        type: Sequelize.UUID,
        references: {model: 'JobberServices',key: 'id',foreignKey: 'service_id'}
      },
      count: {
        type: Sequelize.DECIMAL(10,2)
      },
      price: {
        type: Sequelize.DECIMAL(10,2)
      },
      accepted: {
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
    await queryInterface.dropTable('RequestServices');
  }
};
