require 'spec_helper'

describe IdeaForm do
  
  context 'when the idea does not exist' do
    context 'when the reminder date is specified' do
      it 'should create a new idea with a new user idea for the user' do
        pending
      end
    end

    context 'when the reminder date is not specified' do
      it 'should create a new idea and no user idea' do
        pending
      end
    end
  end

  context 'when the idea already exists' do
    context 'when the user idea for the user already exists' do
      context 'when the reminder date is not specified' do
        it 'should destroy the existing user idea' do
          pending
        end
      end

      context 'when the reminder date is specified' do
        it 'should update the existing idea' do
          pending
        end
      end
    end

    context 'when the user idea for the user does not exist' do
      context 'when the reminder date is not specified' do
        it 'should not create a user idea' do
          pending
        end
      end

      context 'when the reminder date is specified' do
        it 'should create a new user idea for the user' do
          pending
        end
      end
    end
  end
end
