output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_sb_ids" {
  value = aws_subnet.public[*].id
}

output "private_sb_ids" {
  value = aws_subnet.private[*].id
}

output "database_sb_ids" {
  value = aws_subnet.database[*].id
}

output "database_group_name" {
  value = aws_db_subnet_group.default.name
}

output "database_group_id" {
  value = aws_db_subnet_group.default.id
}