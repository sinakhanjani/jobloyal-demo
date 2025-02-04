'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Request extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Request.init({
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      increment: false
    },
    jobber_id: DataTypes.UUID,
    user_id: DataTypes.UUID,
    price: DataTypes.DECIMAL(10,2),
    status: DataTypes.ENUM({values: ["created","accepted","rejected","canceled-by-user","canceled-by-jobber","no-answer-busy","no-answer-free","arrived","started","finished","verified","paid"]}),
    location: 'earth',
    address: DataTypes.STRING,
    job_id: DataTypes.UUID,
    paid: DataTypes.BOOLEAN,
    arrival_time: DataTypes.DECIMAL(3,0),
    time_base: DataTypes.BOOLEAN
  }, {
    sequelize,
    modelName: 'Request',
    tableName: 'Requests',
    underscored: true,
  });
  Request.associate = (models) => {
    Request.belongsToMany(models.JobberService, { through: 'RequestService',foreignKey:{name: 'request_id'},uniqueKey: 'service_id'});
    Request.belongsTo(models.Jobber, { foreignKey:{name: 'jobber_id'}, as: 'jobber' });
    Request.hasMany(models.RequestService, { foreignKey:{name: 'request_id'}, as: 'request_services' });
  }
  return Request;
};
