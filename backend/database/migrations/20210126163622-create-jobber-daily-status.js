'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('JobberDailyStatus', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      status: {
        type: 'public."jobber_status"'
      },
      jobber_id: {
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
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('JobberDailyStatus');
  }
};
