import 'package:fsm_app/model/service_request.dart';

class ServiceController {

  List<ServiceRequest> getAllRequests() {
    return [
      ServiceRequest(
        id: '1',
        category: 'Plumbing',
        description: 'Fix sink',
        status: 'Completed',
        date: '2024-09-26',
        time: '10:00 AM',
        imageUrl: '',
      ),
      ServiceRequest(
        id: '2',
        category: 'Electrical',
        description: 'Light issue',
        status: 'Pending',
        date: '2024-09-27',
        time: '02:00 PM',
        imageUrl: '',
      ),
    ];
  }


  void createServiceRequest(ServiceRequest request) {

  }
}
