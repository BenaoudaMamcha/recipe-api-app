from django.shortcuts import render

# Create your views here.
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Task
from .serializers import TaskSerializer

@api_view(['GET'])
def get_all_tasks(request):
	tasks = Task.objects.all().order_by("-task_time")
	serializer = TaskSerializer(tasks, many=True)
	return Response(serializer.data, status=status.HTTP_200_OK)
	
@api_view(['GET'])
def get_task_details(request, pk):
	task = Task.objects.get(id=pk)
	serializer = TaskSerializer(task, many=False)

	return Response(serializer.data, status=status.HTTP_200_OK)
