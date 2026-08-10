import 'package:autoflow/domain/models.dart';

/// Default RepairX-flavored variable dictionary for the Variables panel.
VariableSchema buildDefaultVariableSchema() {
  return const VariableSchema(
    groups: [
      VariableGroup(
        id: 'ticket',
        label: 'Ticket',
        variables: [
          VariableVar(
            path: 'ticket.id',
            label: 'Ticket ID',
            example: 'T-102',
          ),
          VariableVar(
            path: 'ticket.status',
            label: 'Status',
            example: 'intake',
          ),
          VariableVar(
            path: 'ticket.assignee',
            label: 'Assignee',
            example: 'tech_12',
          ),
          VariableVar(
            path: 'ticket.title',
            label: 'Title',
            example: 'Screen cracked',
          ),
        ],
      ),
      VariableGroup(
        id: 'message',
        label: 'Message',
        variables: [
          VariableVar(
            path: 'message.body',
            label: 'Body',
            example: 'My screen is cracked',
          ),
          VariableVar(
            path: 'message.channel',
            label: 'Channel',
            example: 'sms',
          ),
          VariableVar(
            path: 'message.from',
            label: 'From',
            example: '+15551212',
          ),
        ],
      ),
      VariableGroup(
        id: 'customer',
        label: 'Customer',
        variables: [
          VariableVar(
            path: 'customer.id',
            label: 'Customer ID',
            example: 'cust_9',
          ),
          VariableVar(
            path: 'customer.name',
            label: 'Name',
            example: 'Alex Kim',
          ),
          VariableVar(
            path: 'customer.email',
            label: 'Email',
            type: 'string',
            example: 'alex@example.com',
          ),
        ],
      ),
      VariableGroup(
        id: 'flow',
        label: 'Flow',
        variables: [
          VariableVar(path: 'flow.id', label: 'Flow ID', example: 'flow_sms'),
          VariableVar(
            path: 'flow.name',
            label: 'Flow name',
            example: 'On SMS received',
          ),
          VariableVar(
            path: 'result',
            label: 'Last code result',
            type: 'any',
          ),
        ],
      ),
    ],
  );
}

Map<String, dynamic> buildDefaultSampleRecord() => {
      'ticket': {
        'id': 'T-102',
        'status': 'intake',
        'assignee': null,
        'title': 'Screen cracked',
      },
      'message': {
        'body': 'My screen is cracked',
        'channel': 'sms',
        'from': '+15551212',
      },
      'customer': {
        'id': 'cust_9',
        'name': 'Alex Kim',
        'email': 'alex@example.com',
      },
      'flow': {'id': 'flow_demo', 'name': 'Customer Onboarding Flow'},
    };
