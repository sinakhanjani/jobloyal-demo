'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('JobberStatics', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      jobber_id : {
        type: Sequelize.UUID,
        references: {model: 'Jobbers', key: 'id'}
      },
      sms_enabled: {
        type: Sequelize.BOOLEAN
      },
      notification_enabled: {
        type: Sequelize.BOOLEAN
      },
      pony_period: {
        type: Sequelize.INTEGER
      },
      card_number: {
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
    await queryInterface.dropTable('JobberStatics');
  }
};
