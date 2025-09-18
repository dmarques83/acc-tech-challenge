*** Settings ***
Documentation    E2E API flow: create user, token, authorize, list books, add 2 books, check user details
Resource         ../resources/Account.resource
Resource         ../resources/BookStore.resource
Library          Collections
Library          BuiltIn

Suite Setup      Create Account Sessions

*** Variables ***
${PASSWORD}    P@ssw0rd123!

*** Test Cases ***
BDD - Create user, get token, rent 2 books, verify
    [Tags]    bdd    api
    ${RANDOM_INT}=    Evaluate    random.randint(1000,9999)    modules=random
    ${USERNAME}=       Set Variable    demo_user_${RANDOM_INT}

    Given I create a user with username ${USERNAME} and password ${PASSWORD}
    When I generate an access token for ${USERNAME} and ${PASSWORD}
    And I confirm the user is authorized with ${USERNAME} and ${PASSWORD}
    And I list available books
    And I pick the first two isbns
    And I add the selected books to the user
    Then the user details should contain 2 books

*** Keywords ***
Given I create a user with username ${username} and password ${password}
    Create User    ${username}    ${password}

When I generate an access token for ${username} and ${password}
    Generate Token For User    ${username}    ${password}

And I confirm the user is authorized with ${username} and ${password}
    Check User Authorized    ${username}    ${password}

And I list available books
    List Available Books

And I pick the first two isbns
    Pick First Two Isbns

And I add the selected books to the user
    ${uid}=    Get Variable Value    ${USER_ID}
    ${i1}=     Get Variable Value    ${ISBN1}
    ${i2}=     Get Variable Value    ${ISBN2}
    Add Books To User    ${uid}    ${i1}    ${i2}

Then the user details should contain 2 books
    ${uid}=    Get Variable Value    ${USER_ID}
    ${user}=   Get User Details    ${uid}
    ${books}=  Evaluate    ${user}.get('books') or ${user}.get('booksCollection') or ${user}.get('books', [])
    Length Should Be    ${books}    2
