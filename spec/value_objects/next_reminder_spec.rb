require 'spec_helper'

describe NextReminder do

  describe '#from' do
    context 'when there is no reminder' do
      let(:next_reminder) do
        NextReminder.from DateTime.now.utc,
                          nil
      end

      it 'should return nil' do
        next_reminder.date.should == nil
      end
    end

    context 'when the reminder does not repeat' do
      let(:next_reminder) do
        NextReminder.from DateTime.now.utc,
                          nil, '3/21/2014'
      end

      it 'should return the correct date' do
        next_reminder.date.should == DateTime.new(2014, 3, 21)
      end
    end

    context 'when the reminder repeats every day' do

      let(:next_reminder) do
        NextReminder.from DateTime.now.utc,
                          Repeat::Values[:every_day]
      end

      it 'should set the reminder to tomorrow' do
        next_reminder.date.should == DateTime.now.utc.tomorrow.to_date
      end
    end

    context 'when the reminder repeats every week' do
      

      context 'and when the specified week day already passed this week' do
        let(:next_reminder) do 
          NextReminder.from DateTime.new(2012, 12, 9),
                            Repeat::Values[:every_week],
                            Repeat::Weekdays[:monday]
        end

        it 'should set the reminder next week on the specified day' do
          next_reminder.date.should == DateTime.new(2012, 12, 10).to_date
        end
      end

      context 'and when the specified day isthe same as today' do
        let(:next_reminder) do 
          NextReminder.from DateTime.new(2013, 4, 4),
                            Repeat::Values[:every_week],
                            Repeat::Weekdays[:thursday]
        end

        it 'should set the reminder next week on the specified day' do
          next_reminder.date.should == DateTime.new(2013, 4, 11).to_date
        end
      end

      context 'and when the specified week day didn\'t pass this week' do
        let(:next_reminder) do 
          NextReminder.from DateTime.new(2013, 5, 15),
                            Repeat::Values[:every_week],
                            Repeat::Weekdays[:saturday]
        end

        it 'should set the reminder this week on the specified day' do
          next_reminder.date.should == DateTime.new(2013, 5, 18).to_date
        end
      end


    end

    context 'when the reminder repeats every month' do

      context 'and when the specified day already passed this month' do
        let(:next_reminder) do 
          NextReminder.from DateTime.new(2013, 5, 15),
                            Repeat::Values[:every_month], 5
        end

        it 'should set the reminder next month on the specified day' do
          next_reminder.date.should == DateTime.new(2013, 6, 5).to_date
        end
      end

      context 'and when the specified day is the same as today this month' do
        let(:next_reminder) do 
          NextReminder.from DateTime.new(2013, 5, 20),
                            Repeat::Values[:every_month], 20
        end

        it 'should set the reminder next month on the specified day' do
          next_reminder.date.should == DateTime.new(2013, 6, 20).to_date
        end
      end      

      context 'and when the specified day didn\'t pass this month' do
        let(:next_reminder) do 
          NextReminder.from DateTime.new(2013, 5, 15),
                            Repeat::Values[:every_month], 20
        end

        it 'should set the reminder this month on the specified day' do
          next_reminder.date.should == DateTime.new(2013, 5, 20).to_date
        end
      end
    end

    context 'when the reminder repeats every specified season' do
      context 'and when the specified season didn\'t pass this year' do
        it 'should set the correct date for Spring' do
          next_reminder = NextReminder.from DateTime.new(2013, 1, 1),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:spring]
          next_reminder.date.should == DateTime.new(2013, 3, 1).to_date
        end

        it 'should set the correct date for Summer' do
          next_reminder = NextReminder.from DateTime.new(2013, 4, 1),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:summer]
          next_reminder.date.should == DateTime.new(2013, 6, 1).to_date
        end

        it 'should set the correct date for Autumn' do
          next_reminder = NextReminder.from DateTime.new(2013, 4, 1),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:autumn]
          next_reminder.date.should == DateTime.new(2013, 9, 1).to_date
        end

        it 'should set the correct date for Winter' do
          next_reminder = NextReminder.from DateTime.new(2013, 3, 2),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:winter]
          next_reminder.date.should == DateTime.new(2013, 12, 1).to_date
        end
      end

      context 'and when the specified season already passed this year' do
        it 'should set the correct date for Spring' do
          next_reminder = NextReminder.from DateTime.new(2013, 4, 9),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:spring]
          next_reminder.date.should == DateTime.new(2014, 3, 1).to_date
        end

        it 'should set the correct date for Summer' do
          next_reminder = NextReminder.from DateTime.new(2013, 7, 3),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:summer]
          next_reminder.date.should == DateTime.new(2014, 6, 1).to_date
        end

        it 'should set the correct date for Autumn' do
          next_reminder = NextReminder.from DateTime.new(2013, 10, 1),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:autumn]
          next_reminder.date.should == DateTime.new(2014, 9, 1).to_date
        end

        it 'should set the correct date for Winter' do
          next_reminder = NextReminder.from DateTime.new(2013, 12, 2),
                                        Repeat::Values[:every_season],
                                        Repeat::Seasons[:winter]
          next_reminder.date.should == DateTime.new(2014, 12, 1).to_date
        end
      end
    end

    context 'when the reminder repeats every year' do
      context 'and when the specified date already passed this year' do
        it 'should set the reminder next year on the specified day' do
          next_reminder = NextReminder.from DateTime.new(2013, 11, 2),
                                        Repeat::Values[:every_year],
                                        '10/31'
          next_reminder.date.should == DateTime.new(2014, 10, 31).to_date
        end
      end

      context 'and when the specified data didn\'t pass this year' do
        it 'should set the reminder this year on the specified day' do
          next_reminder = NextReminder.from DateTime.new(2013, 8, 2),
                                        Repeat::Values[:every_year],
                                        '10/31'
          next_reminder.date.should == DateTime.new(2013, 10, 31).to_date
        end
      end
    end
  end
end