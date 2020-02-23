output "dbaddress" {
  value = aws_db_instance.examplemysql.address
  description = "Connect to the database using this endpoint"
}

output "dbport" {
  value = aws_db_instance.examplemysql.port
  description = "database listener port"
}