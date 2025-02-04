'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('CategoryPaths', {
      category_id: {
        type: Sequelize.UUID
      },
      path_id: {
        type: Sequelize.UUID
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('CategoryPaths');
  }
};
