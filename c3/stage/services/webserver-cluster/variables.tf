variable "sg_port" {
  description = "This port will be used for http requestes"
  type = number
  default = 8080
}

variable "alb_sg_port" {
  description = "This port will be used for http requestes"
  type = number
  default = 80
}