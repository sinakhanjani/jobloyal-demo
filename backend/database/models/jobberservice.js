'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class JobberService extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  JobberService.init({
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    jobber_id: DataTypes.UUID,
    job_id: DataTypes.UUID,
    service_id: {
      type: DataTypes.UUID,
      allowNull:true
    },
    unit_id: DataTypes.UUID,
    price: {
      type: DataTypes.DECIMAL(10,2)
    }
  }, {
    sequelize,
    modelName: 'JobberService',
    underscored: true,
    tableName: 'JobberServices',
    paranoid: true,
  });
  JobberService.associate = function (model) {
    JobberService.belongsTo(model.Job,{foreignKey:{name:'job_id'}})
    JobberService.belongsTo(model.Service,{foreignKey:{name:'service_id'}})
    JobberService.belongsTo(model.Unit,{foreignKey:{name:'unit_id'}})
    JobberService.belongsToMany(model.Request, { through: 'RequestService',foreignKey:{name: 'service_id'},uniqueKey: 'service_id'});
  }
  return JobberService;
};
