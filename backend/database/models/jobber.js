'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Jobber extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Jobber.init({
    id:{
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      autoIncrement: false,
    },
    name: DataTypes.STRING,
    family: DataTypes.STRING,
    gender: DataTypes.BOOLEAN,
    email: DataTypes.STRING,
    avatar: DataTypes.STRING,
    zip_code: DataTypes.INTEGER,
    address: DataTypes.TEXT,
    identifier: DataTypes.STRING,
    authorized: DataTypes.BOOLEAN,
    phone_number: DataTypes.STRING,
    birthday: DataTypes.DATE,
    region: {
      type: DataTypes.ENUM,
      values: ["fr","ch"]
    },
    about_us: DataTypes.STRING,
  }, {
    sequelize,
    modelName: 'Jobber',
    underscored: true,
    tableName: "Jobbers",
    paranoid: true,
  });
  Jobber.associate = (models) => {
    Jobber.belongsToMany(models.Job, { through: 'JobberJob',foreignKey:{name: 'jobber_id'} });
  };
  return Jobber;
};
