'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('JobberServices', {
      id: {
        allowNull: false,
        autoIncrement: false,
        primaryKey: true,
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4
      },
      jobber_id: {
        type: Sequelize.UUID,
        references: {model:'Jobbers',key:'id'}
      },
      job_id: {
        type: Sequelize.UUID,
        references: {model:'Jobs',key:'id'}
      },
      service_id: {
        type: Sequelize.UUID,
        references: {model:'Services',key:'id'}
      },
      unit_id: {
        type: Sequelize.UUID,
        allowNull:true,
        references: {model:'Units',key:'id'}
      },
      price: {
        type: Sequelize.DECIMAL(10, 2)
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
    await queryInterface.dropTable('JobberServices');
  }
};
