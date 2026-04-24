# Processing MARC

2002 erklärte Roy Tennant "MARC Must Die" [1]. Aktuell ist das Format "MARC 21" [2] immer noch das meist genutzte Format zum Austausch und Katalogisierung von Metadaten in Bibliotheken. Selbst unsere "Next Generation Library Systems" verwenden diesen Standard aus den 60er Jahren. Da wir auch in den kommenden Jahren mit "MARC 21" arbeiten werden, soll dieser Workshop eine Einführung zu folgenden Themen geben:

* Struktur von "MARC 21"-Datensätzen und ihre verschiedenen Serialisierungen (MARCXML, MARCMaker, MARC-in-JSON, ALEPHSEQ)

* Validierung von "MARC 21"-Datensätzen und häufige Fehler

* Statistische Auswertung von "MARC 21"-Datensätzen 

* Konvertierung von "MARC 21"-Datensätzen

* Metadatenextraktion aus "MARC 21"-Datensätzen

Der Workshop richtet sich an Systembibliothekar*innen und Datenmanager*innen. Für die meisten Aufgaben werden wir Kommandozeilen-Tools wie `yaz-marcdump`, `marcstats`, `marcvalidate` und `catmandu` verwenden, daher sollten die Teilnehmer\*innen mit den Grundlagen der Kommandozeile (CLI) vertraut sein. Für die Übungen wird ein Rechner mit installiertem SSH-Client (z.B. PuTTY [3] benötigt. Die Teilnehmer*innen können ihre eigenen "MARC 21"-Datensets für die praktischen Übungen mitbringen.

[1] http://soiscompsfall2007.pbworks.com/f/marc+must+die.pdf
[2] https://www.loc.gov/marc/
[3] https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html