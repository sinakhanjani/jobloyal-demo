'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class JobberDocument extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  JobberDocument.init({
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    jobber_id: DataTypes.UUID,
    doc_url: DataTypes.STRING,
    accepted: DataTypes.BOOLEAN
  }, {
    sequelize,
    modelName: 'JobberDocument',
    underscored: true,
    tableName: 'JobberDocuments'
  });
  return JobberDocument;
};
