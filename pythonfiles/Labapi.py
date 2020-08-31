import oci
from oci.core.compute_client import ComputeClient
from oci.core.models import UpdateInstanceDetails


# Retrieve data for compute
def updatedata():
    response = computeclient.list_instances(compartment_id=compartment_id).data

    return response

# API calls in functions

def scale_up(vmscale , name):

    data = updatedata()

    try:
        instancedetail = {}
        for r in data:
            """Filter out the json data for instance named bastion only"""
            if r.display_name == name:

                instancedetail = r

        update_instance_details = UpdateInstanceDetails()
        update_instance_details.shape = vmscale

        updatedinstance = computeclient.update_instance(instancedetail.id, update_instance_details)

        response_header = updatedinstance.headers["opc-work-request-id"]
        workrequest = oci.work_requests.WorkRequestClient(config)
        waitfor = workrequest.get_work_request(response_header)

        print("Request to scaled instance has been submitted.")
        print("{} will not be available until request is completed.".format(instancedetail.display_name))
        oci.wait_until(workrequest, waitfor, 'status', 'SUCCEEDED')

        print("Instance has been scaled.")

    except:
        print("Instance does not exist.")



def list_shapes():
    data = updatedata()
    for r in data:
        print(r.display_name)

# Running the program
if __name__ == '__main__':

    """Change this to the location of your config file"""

    config = oci.config.from_file(file_location="<location of the config file>")
    computeclient = ComputeClient(config)
    compartment_id = config["compartment_id"]

    print("Hello user,")
    running = True
    while running:

        print("Choose one of the following 3 options.")
        print()
        print("Input : Descriptions.")
        print()
        print("1 : To scale your compute instance.")
        print("2 : To list shapes in your compartment.")
        print("Exit : To quit.")

        answer = input("")
        print("You have chosen option {}.".format(answer))
        # print(answer)
        if answer == "1":
            print("Which vm do you want to scale up to.")
            print("Input : Descriptions.")
            chooses = {"1":"VM.Standard2.1", "2":"VM.Standard2.2", "3":"VM.Standard2.4"}
            for key in chooses:
                print("{0} : {1}".format(key, chooses[key]))

            answer = input("")

            if answer not in "123":
                print("Please try again")
            else:
                print("Input the name of the instance you want to scale up.")
                name = input()
                scale_up(chooses[answer], name)

        elif answer == "2":
            list_shapes()


        elif answer.lower() == "exit":
            running = False

        else:
            print("Unknown input: Please try again.\n")

        print()

    print("Thank you for using the OCI API today, goodbye.")
    exit
