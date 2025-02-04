'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Message extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Message.hasOne(models.ReplyMessage,{foreignKey: 'message_id', as: 'reply'})
    }
  };
  Message.init({
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      allowNull:false,
      defaultValue: DataTypes.UUIDV4
    },
    user_id: DataTypes.UUID,
    subject: DataTypes.STRING,
    description: DataTypes.TEXT
  }, {
    sequelize,
    modelName: 'Message',
    tableName: 'Messages',
    underscored: true,
  });
  return Message;
};
