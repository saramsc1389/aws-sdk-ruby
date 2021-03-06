# language: en
@cognitoidentity @client
Feature: Amazon Cognito Idenity

  Scenario: Making a basic request
    When I call the "ListIdentityPools" API with:
    | MaxResults | 10 |
    Then the response should contain a list of "IdentityPools"

  Scenario: Error handling
    When I attempt to call the "DescribeIdentityPool" API with:
    | IdentityPoolId | us-east-1:aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee |
    Then I expect the response error code to be "ResourceNotFoundException"
    And I expect the response error message to include:
    """
    IdentityPool 'us-east-1:aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' not found
    """
