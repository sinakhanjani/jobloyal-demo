'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class CategoryPath extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  CategoryPath.init({
    category_id: DataTypes.UUID,
    path_id: DataTypes.UUID
  }, {
    sequelize,
    modelName: 'CategoryPath',
    underscored: true,
  });
  return CategoryPath;
};