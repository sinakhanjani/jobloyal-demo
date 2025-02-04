'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Rates', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      jobber_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobbers', key:'id'}
      },
      job_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobs', key:'id'}
      },
      star1: {
        type: Sequelize.INTEGER(1).UNSIGNED,
        defaultValue: 0
      },
      star2: {
        type: Sequelize.INTEGER(1).UNSIGNED,
        defaultValue: 0
      },
      star3: {
        type: Sequelize.INTEGER(1).UNSIGNED,
        defaultValue: 0
      },
      star4: {
        type: Sequelize.INTEGER(1).UNSIGNED,
        defaultValue: 0
      },
      star5: {
        type: Sequelize.INTEGER(1).UNSIGNED,
        defaultValue: 0
      },
      rate: {
        type: Sequelize.DECIMAL(2,1),
        defaultValue: 0
      },
      work: {
        type: Sequelize.INTEGER.UNSIGNED,
        defaultValue: 0
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
    await queryInterface.dropTable('Rates');
  }
};
