'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Versions', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      device_type: {
        type: 'public."device_type"'
      },
      is_jobber_app: {
        type: Sequelize.BOOLEAN
      },
      description: {
        type: Sequelize.TEXT
      },
      force: {
        type: Sequelize.BOOLEAN
      },
      link: {
        type: Sequelize.STRING
      },
      version_code: {
        type: Sequelize.INTEGER
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
    await queryInterface.dropTable('Versions');
  }
};
