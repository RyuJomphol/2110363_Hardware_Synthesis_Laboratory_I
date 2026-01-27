import os
import re

class VCD():
    def __init__(self):
        self.idToValues = dict()
        self.nameToId = dict()
        self.topModule = None

    def select(self, field):
        return self.idToValues[self.nameToId[field]]
    
    def get_max_time(self):
        max_time = 0
        for id, values in self.idToValues.items():
            if values.keys:
                max_time = max(max_time, values.keys[-1])
        return max_time
    
    def generate_lists(self, max_time=None):
        if max_time is None:
            max_time = self.get_max_time()
        arrays = dict()
        for name, id in self.nameToId.items():
            arrays[name] = self.idToValues[id].generate_list(max_time)
        return arrays

class Module():
    def __init__(self, name=None, parent=None):
        self.name = name
        self.submodules = []
        self.wires = []
        self.parent = self if (parent == None) else parent

    def setName(self, name):
        self.name = name

    def addModule(self, module):
        self.submodules += [module]

    def addWire(self, wire):
        self.wires += [wire]

    def __str__(self):
        res = "Module {0}:\n".format(self.name)
        for wire in self.wires:
            res += "\t{0}\n".format(wire)
        for module in self.submodules:
            res += "{0}\n".format(module)
        return res.strip()

class IntervalList():
    def __init__(self):
        self.keys = []
        self.values = []

    def insert(self, key, value):
        position = len([i for i in self.keys if i < key])
        self.keys.insert(position, key)
        self.values.insert(position, value)
    
    def filterPosedge(self):
        res = IntervalList()
        for i in range(1, len(self.keys)):
            if ((self.values[i-1] == 0) and (self.values[i] > 0)):
                res.insert(i, 1)
        return res

    def filterNegedge(self):
        res = IntervalList()
        for i in range(1, len(self.keys)):
            if ((self.values[i-1] > 0) and (self.values[i] == 0)):
                res.insert(self.keys[i], 1)
        return res
    
    def generate_list(self, max_time=None):
        if max_time is None:
            max_time = self.keys[-1]
        arr = []
        count = 0
        for i in range(len(self.values)):
            upper_bound = self.keys[i+1] if i+1 < len(self.keys) else max_time+1
            while count < upper_bound:
                arr.append(self.values[i])
                count += 1
        return arr

    def __getitem__(self, key):
        position = len([i for i in self.keys if i <= key])
        return self.values[position-1]

    def __str__(self):
        res = "("
        for i in range(len(self.keys)):
            postfix = ", "
            value = self.values[i]
            lower = self.keys[i]
            try:
                upper = self.keys[i+1]-1
            except IndexError as e:
                upper = "Inf."
                postfix = ""
            res += ("[{0}, {1}] -> {2}"+postfix).format(lower, upper, value)
        res += ")"
        return res

    def __repr__(self):
        return self.__str__()

class VCDFactory():
    seperator = "$enddefinitions $end"

    @staticmethod
    def read_raw(filename):
        with open(filename, 'r') as f:
            raw_data = f.read()
        return raw_data

    @staticmethod
    def parseMeta(meta, vcd):
        meta = re.sub('\n+','',re.sub(' +',' ',meta)).replace(" $end "," $end")
        meta = meta.split(" $end")[:-1]
        pointer = Module()
        for elem in meta:
            data = elem.split(" ")
            if (data[0] == "$var"):
                vcd.nameToId.setdefault(data[4], data[3])
                values = vcd.idToValues.setdefault(data[3], IntervalList())
                pointer.addWire(Wire(data[2], data[3], data[4], values))
            elif (data[0] == "$scope"):
                if (vcd.topModule is None):
                    pointer.setName(data[2])
                    vcd.topModule = pointer
                else:
                    module = Module(data[2], parent=pointer)
                    pointer.addModule(module)
                    pointer = module
            elif (data[0] == "$upscope"):
                pointer = pointer.parent

    @staticmethod
    def convert(string):
        if (string[0] in ('b', 'h')):
            string = '0'+string
        return eval(string)

    @staticmethod
    def parseData(data, vcd):
        data = data.strip().split("\n")
        timestamp = 0
        for line in data:
            line = line.strip()
            if line.startswith('#'):
                timestamp = int(line[1:])
            elif line:
                if line[0] in ('0', '1', 'x', 'z', 'X', 'Z'):
                    value = int(line[0]) if line[0] in ('0', '1') else line[0].lower()
                    signal_id = line[1:]
                    if signal_id in vcd.idToValues:
                        vcd.idToValues[signal_id].insert(timestamp, value)
                elif line[0] in ('b', 'B'):
                    parts = line.split()
                    binary_value = parts[0][1:]
                    signal_id = parts[1]
                    try:
                        value = int(binary_value, 2)
                    except ValueError:  # handle 'x' or 'z' in binary values
                        value = binary_value.lower()
                    if signal_id in vcd.idToValues:
                        vcd.idToValues[signal_id].insert(timestamp, value)
        

    @staticmethod
    def parse(raw_data):
        # Pre-process the raw data
        index = raw_data.find(VCDFactory.seperator)
        meta = raw_data[:index]
        data = raw_data[index+len(VCDFactory.seperator):]
        # Create the VCD object
        vcd = VCD()
        # Parse raw data and populate the VCD object accordingly
        VCDFactory.parseMeta(meta, vcd)
        VCDFactory.parseData(data, vcd)
        return vcd

    @staticmethod
    def read(filename):
        return VCDFactory.parse(VCDFactory.read_raw(filename))

class Wire():
    def __init__(self, bitwidth, id, name, values=None):
        self.bitwidth = bitwidth
        self.values = values
        self.name = name
        self.id = id

    def __str__(self):
        return "Wire(width : {0}, id : {1}, name : {2}) -> {3}".format(self.bitwidth, self.id, self.name, self.values.__str__()[:50])

    def __repr__(self):
        return self.__str__()
    
class VCDTestbench():
    def __init__(self, vcd):
        self.vcd = vcd
        self.data = None
        self.checked_count = 0
        self.passed_count = 0
    
    def run(self):
        try:
            self.data = self.vcd.generate_lists()

            clk = self.data['clk']
            rst = self.data['rst']
            data_in = self.data['data_in']
            state = self.data['state']
            data_out = self.data['data_out']
            
            is_reset = False
            testcases = [
                ('A -> D (in = 0)', 0, 3, 0), 
                ('A -> B (in = 1)', 0, 1, 1),
                ('B -> D (in = 0)', 1, 3, 0), 
                ('B -> C (in = 1)', 1, 2, 1), 
                ('C -> D (in = 0)', 2, 3, 0), 
                ('C -> B (in = 1)', 2, 1, 1), 
                ('D -> A (in = 0)', 3, 0, 0), 
                ('D -> B (in = 1)', 3, 1, 1),
            ]
            
            state_output_map = {
                0: 0b01,
                1: 0b11,
                2: 0b00,
                3: 0b10,
            }
            
            testcases_checked = {k: False for k in testcases}
            
            for t in range(1, len(clk)):
                # Find rising edge of clk
                if clk[t-1] == 0 and clk[t] == 1:
                    current_rst = rst[t-1]
                    current_state = state[t-1]
                    current_data_in = data_in[t-1]
                    next_state = state[t]
                    next_data_out = data_out[t]
                    
                    if current_rst == 1 and next_state == 0 and next_data_out == state_output_map[0]:
                        is_reset = True
                    elif is_reset:
                        for testcase in testcases:
                            desc, src, dst, inp = testcase
                            if (not testcases_checked[testcase] and current_state == src and current_data_in == inp):
                                if next_state == dst and next_data_out == state_output_map[dst]:
                                    testcases_checked[testcase] = True
                        
            self.checked_count = len(testcases) + 1
            self.passed_count = sum(1 for v in testcases_checked.values() if v) + (1 if is_reset else 0)
                        
            # Print result
            print("--------------------------")
            # Reset check
            if is_reset:
                print("✔ Reset: Found")
            else:
                print("✘ Reset: Not Found")
            # Testcase checks
            for testcase, passed in testcases_checked.items():
                desc, _, _, _ = testcase
                if passed:
                    print(f"✔ {desc}: Found")
                else:
                    print(f"✘ {desc}: Not Found")
            
            # Print summary
            self.print_summary()
        except Exception as e:
            self._print_error(e)
            return
        
    
    def print_summary(self):
        print("--------------------------")
        print(f"Test Summary: {'PASS' if self.passed_count == self.checked_count else 'FAIL'}")
        print(f"{self.passed_count}/{self.checked_count} test cases passed ({(self.passed_count / self.checked_count) * 100 if self.checked_count > 0 else 0 :.2f}%)")
    
    def _print_error(self, error):
        print("--------------------------")
        print(f"Test Summary: FAIL")
        thrown_type = type(error).__name__
        print(f"{thrown_type}: {str(error)}")


if __name__ == "__main__":
    os.system("iverilog -o fsm_tb.vvp fsm.v fsm_tb.v")
    os.system("vvp fsm_tb.vvp")
    
    vcd = VCDFactory.read("fsm_tb.vcd")
    
    tb = VCDTestbench(vcd)
    tb.run()
    
    # Clear the vvp and vcd files after verification
    if os.path.exists("fsm_tb.vvp"):
        os.remove("fsm_tb.vvp")
    if os.path.exists("fsm_tb.vcd"):
        os.remove("fsm_tb.vcd")