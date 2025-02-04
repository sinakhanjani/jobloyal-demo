'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Users', {
      id: {
        allowNull: false,
        autoIncrement: false,
        primaryKey: true,
        type: Sequelize.UUID
      },
      name: {
        type: Sequelize.STRING
      },
      family: {
        type: Sequelize.STRING
      },
      gender:{
        type: Sequelize.BOOLEAN
      },
      email: {
        type: Sequelize.STRING
      },
      address: {
        type: Sequelize.TEXT
      },
      phone_number: {
        type: Sequelize.STRING,
        unique: true
      },
      birthday: {
        type: Sequelize.DATE
      },
      region: {
        type: 'public."region"',
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      },
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Users');
  }
};
