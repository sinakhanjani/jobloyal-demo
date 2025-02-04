'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Services', {
      id: {
        allowNull: false,
        autoIncrement: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      title: {
        type: Sequelize.STRING
      },
      default_unit_id: {
        type: Sequelize.UUID,
        references: {model: 'Units', key: 'id'}
      },
      creator_user_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobbers', key: 'id'}
      },
      job_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobs', key: 'id'}
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
    await queryInterface.dropTable('Services');
  }
};
