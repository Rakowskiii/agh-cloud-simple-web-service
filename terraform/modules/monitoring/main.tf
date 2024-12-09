resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("cw_agent_config.json")
}

resource "aws_cloudwatch_metric_alarm" "alarm_elb" {
  alarm_name                = "ELB_400_requests_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 10
  alarm_description         = "Request error rate has exceeded 10%"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m2/m1*100"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 120
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.load_balancer.arn_suffix
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "HTTPCode_ELB_4XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 120
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.load_balancer.arn_suffix
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "logins_rds" {
  alarm_name                = "Connections_Attempts_RDS"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  threshold                 = 1000
  alarm_description         = "Connections to RDS exceeded 1000 in last 2 minutes"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m1"
    label       = "Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "DatabaseConnections"
      namespace   = "AWS/RDS"
      period      = 120
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = var.rds.identifier
      }
    }
  }

}
