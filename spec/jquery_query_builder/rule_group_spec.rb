require 'spec_helper'

describe JqueryQueryBuilder::RuleGroup do
  let(:decimal_rule) do
    {
      'id' =>     "Decimal_Question",
      'field' =>  "Decimal_Question",
      'type' =>   "double",
      'input' =>  "text",
      'operator' => "equal",
      'value' =>  "1.2"
    }
  end
  let(:boolean_rule) do
    {
      "id" => "Yes_No_Question",
      "field" => "Yes_No_Question",
      "type" => "boolean",
      "input" => "select",
      "operator" => "equal",
      "value" => "true"
    }
  end
  let(:not_contains_rule) do
    {
      "id" => "Subject_Query",
      "field" => "Subject_Query",
      "type" => "string",
      "input" => "select",
      "operator" => "not_contains",
      "value" => "[Urgent]"
    }
  end

  describe '#new' do
    it 'should initialize a new rule group and get the conditions and rules' do
      evaluator = JqueryQueryBuilder::RuleGroup.new({
        'condition' => 'AND',
        'rules' => [decimal_rule]
      })
      expect(evaluator.condition).to eq('AND')
      expect(evaluator.rules).to eq([decimal_rule])
    end
  end

  describe '#evaluate' do
    context 'AND' do
      let(:rules) do
        [decimal_rule, boolean_rule, not_contains_rule]
      end

      let(:evaluator) do
        JqueryQueryBuilder::RuleGroup.new({
          'condition' => 'AND',
          'rules' => rules
        })
      end

      it 'should returns true if all are true' do
        expect(evaluator.evaluate({"Decimal_Question" => 1.2, "Yes_No_Question" => true, "Subject_Query" => "[Low]"})).to eq true
      end

      it 'should return false if any are false' do
        expect(evaluator.evaluate({"Decimal_Question" => 1.2, "Yes_No_Question" => false, "Subject_Query" => "[Urgent]"})).to eq false
      end

      context 'with a rule that is not_contains' do
        context 'when a field is not passed' do
          it 'should return false' do
            expect(evaluator.evaluate({"Decimal_Question" => 1.2, "Yes_No_Question" => true})).to eq false
          end
        end
      end
    end

    context 'OR' do
      let(:rules){[decimal_rule, boolean_rule, not_contains_rule]}
      let(:evaluator){
        JqueryQueryBuilder::RuleGroup.new({
          'condition' => 'OR',
          'rules' => rules
        })
      }
      it 'should returns true if any are true' do
        expect(evaluator.evaluate({"Decimal_Question" => 1.5, "Yes_No_Question" => true})).to eq true
      end
      it 'should return false if all are false' do
        expect(evaluator.evaluate({"Decimal_Question" => 1.0, "Yes_No_Question" => false})).to eq false
      end
    end
  end

  describe '#get_rule_object' do
    context 'passed a rule' do
      it 'should return a rule object' do
        result = JqueryQueryBuilder::RuleGroup.new({}).get_rule_object(decimal_rule)
        expect(result.is_a?(JqueryQueryBuilder::Rule)).to eq(true)
      end
    end
    context 'passed a rule group' do
      it 'should return a rule group' do
        result = JqueryQueryBuilder::RuleGroup.new({}).get_rule_object({'condition' => 'AND', 'rules' => [{}]})
        expect(result.is_a?(JqueryQueryBuilder::RuleGroup)).to eq(true)
      end
    end
  end
end
