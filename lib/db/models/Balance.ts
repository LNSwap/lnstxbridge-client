import { Model, Sequelize, DataTypes } from 'sequelize';

type BalanceType = {
  symbol: string;
  walletBalance: number;
  lightningBalance: number;
};

class Balance extends Model implements BalanceType {
  public symbol!: string;
  public walletBalance!: number;
  public lightningBalance!: number;

  public static load = (sequelize: Sequelize): void => {
    Balance.init({
      symbol: { type: new DataTypes.STRING(255), primaryKey: true },
      walletBalance: { type: new DataTypes.INTEGER(), allowNull: true },
      lightningBalance: { type: new DataTypes.INTEGER(), allowNull: true },
    }, {
      sequelize,
      tableName: 'balances',
    });
  }
}

export default Balance;
export { BalanceType };
