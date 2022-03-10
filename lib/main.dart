// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:smartcontract/slider.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spacecoin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Spacecoin',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  final myAddress = '0x4818569AA9dE13d3cC1D702Cd10a95932799a674';

  bool data = false;
  int myAmount = 0;
  var mydata;
  late String transHash;

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(
        'https://rinkeby.infura.io/v3/5d3ba1164b1a450a9a1e93d79b393e21',
        httpClient);
    print('ssddd');

    super.initState();
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddress = '0x50338cAF974F2ec1869020e83eF48E36aCE93caf';
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'spacecoin'),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    //
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);

    // This line below doesn't work.
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);

    // print(result.toString());
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    // print('In getGreeting');
    List<dynamic> result = await query('getBalance', []);

    print('In getGreeting');
    print(result[0]);

    mydata = result[0];
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "0x52bd70b92aa91ec932a6224dc9fad8b11b8fb22261bdcf9f74a2d9c560ffbd08");

    final DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<String> reciveCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit('depositBalance', [bigAmount]);
    print('Deposited');
    transHash = response;
    setState(() {});
    return response;
  }

  Future<String> WithdrawCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit('withdrawBalance', [bigAmount]);
    print('Withdrawn');
    transHash = response;
    setState(() {});
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          Container(
            color: Colors.blue.shade900,
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: Center(child: Text("\$SpaceCoin")),
          ),
          SizedBox(height: 300),
          Center(
            child: Card(
              shadowColor: Colors.black38,
              elevation: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                height: 100,
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("balance"),
                    data
                        ? Text('\$ $mydata')
                        : const CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 400),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SliderWidget(
                    min: 0,
                    max: 100,
                    finalVal: (value) {
                      myAmount = (value * 100).round();
                      print('uuu');
                      print(myAmount);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton(
                        onPressed: () => getBalance(myAddress),
                        child: const Text(
                          'Refresh',
                        ),
                        color: Colors.blue,
                      ),
                      FlatButton(
                        onPressed: () => reciveCoin(),
                        child: const Text(
                          'Deposit',
                        ),
                        color: Colors.green,
                      ),
                      FlatButton(
                        onPressed: () => reciveCoin(),
                        child: const Text(
                          'Withdraw',
                        ),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
