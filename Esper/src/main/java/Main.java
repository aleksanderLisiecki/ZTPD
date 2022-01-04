import java.io.IOException;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.runtime.client.EPRuntime;
import com.espertech.esper.runtime.client.EPRuntimeProvider;
import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;


public class Main {
    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        // zad 5
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//            "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                    "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 days)");

        // zad 6
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//            "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                    "from KursAkcji(spolka in ('Honda', 'IBM', 'Microsoft')).win:ext_timed_batch(data.getTime(), 1 days)");

        // zad 7a
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, kursOtwarcia, kursZamkniecia, spolka " +
//                        "from KursAkcji.win:length(1)" +
//                        "where kursZamkniecia > kursOtwarcia");

        // zad 7b
        // Metoda w klasie KursAkcji:
//        public static boolean kursZamknieciaWiekszyOdKursuOtwarcia(double kursOtwarcia, double kursZamkniecia){
//            return kursZamkniecia > kursOtwarcia;
//        }

//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, kursOtwarcia, kursZamkniecia, spolka " +
//                        "from KursAkcji(KursAkcji.kursZamknieciaWiekszyOdKursuOtwarcia(kursOtwarcia, kursZamkniecia)).win:length(1)");

        // zad 8
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed(data.getTime(), 7 days)");

        // zad 9
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, spolka, kursZamkniecia, max(kursZamkniecia)" +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed_batch(data.getTime(), 1 days)" +
//                        "having max(kursZamkniecia) = kursZamkniecia");

        // zad 10
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream max(kursZamkniecia) as maksimum " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 7 days)");

        // zad 11
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream pep.kursZamkniecia as kursPep, coc.kursZamkniecia as kursCoc, pep.data " +
//                        "from KursAkcji(spolka = 'CocaCola').win:length(1) as coc join " +
//                        "KursAkcji(spolka = 'PepsiCo').win:length(1) as pep " +
//                        "where pep.kursZamkniecia > coc.kursZamkniecia");

        // zad 12
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream k.spolka, k.data, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - p.kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:length(1) as k join " +
//                        "KursAkcji(spolka in ('PepsiCo', 'CocaCola')).std:firstunique(spolka) as p " +
//                        "on k.spolka = p.spolka");

        // zad 13
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream k.spolka, k.data, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - p.kursZamkniecia as roznica " +
//                        "from KursAkcji.win:length(1) as k join " +
//                        "KursAkcji.std:firstunique(spolka) as p " +
//                        "on k.spolka = p.spolka " +
//                        "where k.kursZamkniecia > p.kursZamkniecia");

        // zad 14
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream k.data, p.data, k.spolka, k.kursOtwarcia, p.kursOtwarcia " +
//                        "from KursAkcji.win:ext_timed(data.getTime(), 7 days) as k join " +
//                        "KursAkcji.win:ext_timed(data.getTime(), 7 days) as p " +
//                        "on k.spolka = p.spolka " +
//                        "where k.kursOtwarcia - p.kursOtwarcia > 3");

        // zad 15
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, spolka, obrot " +
//                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
//                        "order by obrot desc limit 3");

        // zad 16
        EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka, obrot " +
                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                        "order by obrot desc limit 2, 1");

        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }


        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();
        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }


}
