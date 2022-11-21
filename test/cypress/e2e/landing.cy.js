/* global cy */
describe('The landing page', function () {
  it('should load ', function () {
    cy.visit('/exist/apps/ro-test/index.html')
      .get('.alert')
      .contains('app.xqm')
  })

})
