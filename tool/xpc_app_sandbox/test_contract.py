import copy
import errno
import unittest
from contract import assess

class ContractTests(unittest.TestCase):
    def sample(self):
        actor = {"privateWorkWrite": {"allowed": True, "errno": 0},
                 "callerRead": {"allowed": True, "errno": 0}}
        for field in ("network", "callerWrite", "outsideWorkWrite"):
            actor[field] = {"allowed": False, "errno": errno.EPERM}
        return {"syntheticOnly": True, "childExit": 0,
                "service": copy.deepcopy(actor), "child": copy.deepcopy(actor)}
    def test_container_write_is_a_regression(self):
        data=self.sample();data["service"]["outsideWorkWrite"]={"allowed":True,"errno":0}
        self.assertIn("service:outsideWorkWrite_not_proven_denied",assess(data)["gaps"])
    def test_child_requires_independent_validation(self):
        data=self.sample();data["child"]["network"]={"allowed":True,"errno":0}
        self.assertIn("child:network_not_proven_denied",assess(data)["gaps"])
    def test_connection_refused_does_not_prove_network_isolation(self):
        data=self.sample();data["service"]["network"]={"allowed":False,"errno":errno.ECONNREFUSED}
        self.assertIn("service:network_not_proven_denied",assess(data)["gaps"])
    def test_missing_file_does_not_prove_write_isolation(self):
        data=self.sample();data["child"]["callerWrite"]={"allowed":False,"errno":errno.ENOENT}
        self.assertIn("child:callerWrite_not_proven_denied",assess(data)["gaps"])
    def test_denied_inputs_require_transport(self):
        data=self.sample();data["service"]["callerRead"]={"allowed":False,"errno":errno.EPERM}
        self.assertIn("service:input_transfer_required",assess(data)["gaps"])
    def test_missing_or_crashed_child_never_certifies_migration(self):
        data=self.sample();data.pop("child");data["childExit"]=78
        self.assertIn("native_probe_incomplete",assess(data)["gaps"])
        self.assertFalse(assess(data)["readyForProduction"])
    def test_kernel_permissions_alone_do_not_certify_real_engines(self):
        self.assertFalse(assess(self.sample())["readyForProduction"])
        self.assertIn("pdfa_cda_docx_engines_not_verified",assess(self.sample())["gaps"])

if __name__ == '__main__': unittest.main()
