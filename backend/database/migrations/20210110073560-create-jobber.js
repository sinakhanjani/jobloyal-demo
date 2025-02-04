'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Jobbers', {
      id: {
        allowNull: false,
        autoIncrement: false,
        type: Sequelize.UUID,
        primaryKey: true,
        defaultValue: Sequelize.UUIDV4
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
      avatar: {
        type: Sequelize.STRING
      },
      zip_code: {
        type: Sequelize.INTEGER
      },
      address: {
        type: Sequelize.TEXT
      },
      authorized: {
        type: Sequelize.BOOLEAN
      },
      phone_number: {
        type: Sequelize.STRING,
        unique: true
      },
      birthday: {
        type: Sequelize.DATE
      },
      identifier: {
        type:Sequelize.STRING,
        unique: true
      },
      region: {
        type: 'public."region"',
      },
      about_us: {
        type: Sequelize.TEXT
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
    await queryInterface.dropTable('Jobbers');
  }
};
