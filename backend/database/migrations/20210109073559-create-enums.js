'use strict';
module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.sequelize.query('CREATE TYPE public."request_status" AS ENUM (\'created\', \'accepted\', \'canceled-by-user\', \'canceled-by-jobber\', \'no-answer-busy\', \'no-answer-free\', \'arrived\', \'started\', \'finished\', \'verified\', \'paid\', \'done\', \'rejected\',\'deposited\')');
        await queryInterface.sequelize.query('CREATE TYPE public."region" AS ENUM (\'fr\', \'ch\',\'en\')');
        await queryInterface.sequelize.query('CREATE TYPE public."jobber_status" AS ENUM (\'online\', \'offline\',\'busy\')');
        await queryInterface.sequelize.query('CREATE TYPE public."device_type" AS ENUM (\'android\', \'ios\',\'web\')')
    },
    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropAllEnums()
    }
};
