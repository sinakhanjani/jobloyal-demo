'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Comment extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Comment.init({
    comment: DataTypes.TEXT,
    rate: DataTypes.INTEGER,
    request_id: DataTypes.UUID,
    job_id: DataTypes.UUID,
    jobber_id: DataTypes.UUID,
    service_id: DataTypes.UUID
  }, {
    sequelize,
    modelName: 'Comment',
    tableName: 'Comments',
    underscored: true,
    updatedAt: false
  });
  return Comment;
};
