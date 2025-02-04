'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class ReplyMessage extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  ReplyMessage.init({
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      allowNull:false,
      defaultValue: DataTypes.UUIDV4
    },
    message_id: DataTypes.UUID,
    answer: DataTypes.TEXT
  }, {
    sequelize,
    modelName: 'ReplyMessage',
    tableName: 'ReplyMessages',
    underscored: true,
  });
  return ReplyMessage;
};
