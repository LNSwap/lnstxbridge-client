import { Op, WhereOptions } from 'sequelize';
import Balance, { BalanceType } from './models/Balance';

class BalanceRepository {
  public getBalances = (): Promise<Balance[]> => {
    return Balance.findAll();
  }

  public getBalance = (options: WhereOptions): Promise<Balance | null> => {
    return Balance.findOne({
      where: options,
    });
  }

  public findBalance = async (symbol: string, walletBalance: number, lightningBalance: number): Promise<Balance> => {
    const [balance] = await Balance.findOrCreate({
      where: {
        symbol: {
          [Op.eq]: symbol,
        }
      },
      defaults: {
        symbol,
        walletBalance,
        lightningBalance,
      },
    });

    console.log('findBalance: ', symbol, JSON.stringify(balance));
    return balance;
  }

  public addBalance = (balance: BalanceType): Promise<Balance> => {
    return Balance.create(balance);
  }

  public updateBalance = (balance: Balance, walletBalance: number, lightningBalance: number): Promise<Balance> => {
    return balance.update({
      walletBalance,
      lightningBalance,
    });
  }
}

export default BalanceRepository;
