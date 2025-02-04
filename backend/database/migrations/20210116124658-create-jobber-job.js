'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('JobberJobs', {
      jobber_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobbers',key:"id"}
      },
      job_id: {
        type: Sequelize.UUID,
        references: {model: 'Jobs',key:"id"}
      },
      enabled: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      deleted_at: {
        allowNull: true,
        type: Sequelize.DATE
      },
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('JobberJobs');
  }
};
