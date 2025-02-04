'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  User.init({
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
    address: DataTypes.TEXT,
    phone_number: DataTypes.STRING,
    birthday: DataTypes.DATE,
    region: {
      type: DataTypes.ENUM,
      values: ["fr","ch"]
    },
  }, {
    sequelize,
    modelName: 'User',
    tableName: "Users",
    underscored: true,
    paranoid: true,
  });
  return User;
};
