Feature: Status command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          stack1:
            template: stack1.json
          stack2:
            template: stack2.json
      """
    And a directory named "parameters"
    And a file named "parameters/stack1.yml" with:
      """
      KeyName: my-key
      """
    And a directory named "templates"
    And a file named "templates/stack1.json" with:
      """
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Test template",
  "Parameters": {
    "InstanceTypeParameter" : { "Type" : "String" }
  },
  "Mappings": {},
  "Resources": {
    "MyAwesomeQueue" : {
      "Type" : "AWS::SQS::Queue",
      "Properties" : {
        "VisibilityTimeout" : "1"
      }
    }
  },
  "Outputs": {}
}
      """
    And a file named "templates/stack2.json" with:
      """
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Test template",
  "Parameters": {},
  "Mappings": {},
  "Resources": {
    "MoarQueue" : {
      "Type" : "AWS::SQS::Queue",
      "Properties" : {
        "VisibilityTimeout" : "1"
      }
    }
  },
  "Outputs": {}
}
      """
    And I set the environment variables to:
      | variable | value |
      | STUB_AWS | true  |

  Scenario: Run status command and get a list of stack statuii
    Given I set the environment variables to:
      | variable | value |
      | ANSWER   | y     |
    And I stub the following stacks:
      | stack_id | stack_name | parameters     | region    |
      |        1 | stack1     | KeyName=my-key | us-east-1 |
      |        2 | stack2     |                | us-east-1 |
    And I stub a template for the stack "stack1":
      """
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Test template",
  "Parameters": {
    "InstanceTypeParameter" : { "Type" : "String" }
  },
  "Mappings": {},
  "Resources": {
    "MyAwesomeQueue" : {
      "Type" : "AWS::SQS::Queue",
      "Properties" : {
        "VisibilityTimeout" : "7"
      }
    }
  },
  "Outputs": {}
}
      """
    And I stub a template for the stack "stack2":
      """
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Test template",
  "Parameters": {},
  "Mappings": {},
  "Resources": {
    "MoarQueue" : {
      "Type" : "AWS::SQS::Queue",
      "Properties" : {
        "VisibilityTimeout" : "1"
      }
    }
  },
  "Outputs": {}
}
      """

    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type | timestamp           |
      |        1 |        1 | stack1     | -                   | CREATE_COMPLETE | -             | 2020-10-29 00:00:00 |
      |        1 |        1 | stack2     | -                   | CREATE_COMPLETE | -             | 2020-10-29 00:00:00 |
    When I run `stack_master status --trace` interactively
    And the output should contain all of these lines:
      | REGION    \| STACK_NAME \| STACK_STATUS    \| DIFFERENT |
      | ----------\|------------\|-----------------\|---------- |
      | us-east-1 \| stack1     \| CREATE_COMPLETE \| Yes       |
      | us-east-1 \| stack2     \| CREATE_COMPLETE \| No        |
      
    Then the exit status should be 0
