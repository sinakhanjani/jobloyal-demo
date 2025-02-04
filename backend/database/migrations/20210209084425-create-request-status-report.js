'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('RequestStatusReport', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER,

      },
      request_id: {
        type: Sequelize.UUID
      },
      status: {
        type: 'public."request_status"'
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });

    await queryInterface.sequelize.query('CREATE OR REPLACE FUNCTION save_report_of_requests() RETURNS TRIGGER AS $request_report$\n' +
        '    BEGIN\n' +
        '\t\tINSERT INTO public."RequestStatusReport" (request_id, status, created_at) SELECT NEW.id,NEW.status,NOW();\n' +
        '        RETURN NULL;\n' +
        '    END;\n' +
        '$request_report$ LANGUAGE plpgsql;\n' +
        '\n' +
        'CREATE TRIGGER requests_report\n' +
        'AFTER INSERT OR UPDATE ON public."Requests"\n' +
        '    FOR EACH ROW EXECUTE PROCEDURE save_report_of_requests();')
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('RequestStatusReport');
    await queryInterface.dropTrigger('Requests','save_report_of_requests');
  }
};
