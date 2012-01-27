class HomeController < ApplicationController
  def index
    @flights = Flight.find(:all, :conditions => ["unix_timestamp(flight_date)+86400>=unix_timestamp(now())"], :include => [:tickets])
    @flights = @flights.sort{|b,a| a.tickets.length.to_s+(86400*36500-a.flight_date.to_i).to_s <=> b.tickets.length.to_s+(86400*36500-b.flight_date.to_i).to_s}[0..20]
  end
  def flight_query
    if params[:flight]
      params[:flight][:airport_code_from] = params[:flight][:airport_code_from1]
      params[:flight][:airport_code_to] = params[:flight][:airport_code_to1]
      if params[:flight][:flight_date].to_s!=""
        @flights = Flight.find(:all, :conditions => ["unix_timestamp(flight_date)+86400>=unix_timestamp(now()) and (date(flight_date)=? or ?='') and (airport_code_from like ? or ?='') and (airport_code_to like ? or ?='') and (airline like ? or ?='') and (flight_name like ? or ?='')",Date.parse(params[:flight][:flight_date]),Date.parse(params[:flight][:flight_date]),params[:flight][:airport_code_from]+'%',params[:flight][:airport_code_from],params[:flight][:airport_code_to]+'%',params[:flight][:airport_code_to],'%'+params[:flight][:airline]+'%',params[:flight][:airline],'%'+params[:flight][:flight_name]+'%',params[:flight][:flight_name]], :include => [:tickets])
      else
        @flights = Flight.find(:all, :conditions => ["unix_timestamp(flight_date)+86400>=unix_timestamp(now()) and (airport_code_from like ? or ?='') and (airport_code_to like ? or ?='') and (airline like ? or ?='') and (flight_name like ? or ?='')",params[:flight][:airport_code_from]+'%',params[:flight][:airport_code_from],params[:flight][:airport_code_to]+'%',params[:flight][:airport_code_to],'%'+params[:flight][:airline]+'%',params[:flight][:airline],'%'+params[:flight][:flight_name]+'%',params[:flight][:flight_name]], :include => [:tickets])
      end 
      @flights = @flights.sort{|b,a| a.tickets.length.to_s+(86400*36500-a.flight_date.to_i).to_s <=> b.tickets.length.to_s+(86400*36500-b.flight_date.to_i).to_s}[0..20]
      @flight_temp = params[:flight]
      render :layout => false
    end
  end
  def flight_new
    if params[:flight] and params[:flight][:flight_name].to_s!="" and params[:flight][:flight_date].to_s!="" and params[:flight][:airline].to_s!="" and params[:flight][:airport_code_to].to_s!="" and params[:flight][:airport_code_from].to_s!=""
      if valid_airport(params[:flight][:airport_code_from]) and valid_airport(params[:flight][:airport_code_to])
        flight_date = Date.parse(params[:flight][:flight_date]) 
        if flight = Flight.find(:first, :conditions => ["date(flight_date)=? and airport_code_from=? and airport_code_to=? and airline=? and flight_name=?",Date.parse(params[:flight][:flight_date]),params[:flight][:airport_code_from].upcase,params[:flight][:airport_code_to].upcase,params[:flight][:airline], params[:flight][:flight_name].upcase], :include => [:tickets])
        else
          flight = Flight.new(:flight_name => params[:flight][:flight_name].upcase, :flight_date => Date.parse(params[:flight][:flight_date]), :airport_code_from => params[:flight][:airport_code_from].upcase, :airport_code_to => params[:flight][:airport_code_to].upcase, :airline => params[:flight][:airline])
          flight.save
        end
        redirect_to :controller => :ticket, :action => :flight, :id => flight.id
      else
        @flights = Array.new
        @flight_temp = params[:flight]
        flash.now[:error] = "Please use valid airport codes for your new flight."
        render :action => :index
      end
    else
      @flights = Array.new
      @flight_temp = params[:flight]
      flash.now[:error] = "Please enter all information for your new flight."
      render :action => :index
    end
  end
  def airport_codes
    airport_codes = ["ABR", "ABI", "ADK", "KKI", "AKI", "CAK", "KQA", "AUK", "ALM", "ALS", "ALB", "CVO", "QWY", "ABQ", "WKK", "AEX", "AET", "ABE", "AIA", "APN", "AOO", "AMA", "ABL", "AKP", "ANC", "AGN", "ANI", "ANV", "ATW", "ACV", "ARC", "AVL", "HTS", "ASE", "AHN", "AKB", "ATL", "AIY", "ATK", "AGS", "AUG", "AUS", "BFL", "BWI", "BGR", "BHB", "BRW", "BTI", "BTR", "MBS", "BPT", "ZBV", "WBQ", "BKW", "BED", "BLV", "BLI", "BJI", "BEH", "BET", "ABE", "BTT", "BIL", "GPT", "BGM", "KBC", "BHM", "BIS", "BID", "BMI", "BLF", "BOI", "BOS", "XHH", "WHH", "WBU", "BYA", "BWG", "BZN", "BFD", "BRD", "BWD", "QKB", "TRI", "BKX", "RBH", "BRO", "BQK", "BKC", "BUF", "IFP", "BUR", "BRL", "BTV", "BTM", "CAK", "CGI", "LUR", "EHM", "MDH", "CLD", "CNM", "MRY", "CPR", "CDC", "CID", "CEM", "CDR", "CIK", "CMI", "CHS", "CRW", "CLT", "CHO", "CHA", "CYF", "VAK", "CYS", "CHI", "MDW", "ORD", "CKX", "CIC", "KCG", "KCQ", "KCL", "CZN", "HIB", "CHU", "CVG", "CHP", "IRC", "CLP", "CKB", "PIE", "CLE", "CVN", "COD", "CFA", "KCC", "CDB", "CLL", "COS", "COU", "CAE", "CSG", "GTR", "CMH", "CCR", "CNK", "QCE", "CDV", "CRP", "CEZ", "CGA", "CEC", "CKO", "CUW", "CBE", "DAL", "DFW", "DAY", "DAB", "DEC", "DRG", "DRT", "DJN", "DEN", "QWM", "DSM", "DTT", "DTW", "DVL", "DIK", "DLG", "DDC", "DHN", "DUJ", "DBQ", "DLH", "DRO", "RDU", "RDU", "DUT", "ABE", "EAU", "EDA", "EEK", "KKU", "KEK", "IPL", "ELD", "ELP", "ELV", "ELI", "EKO", "ELM", "LYU", "EMK", "BGM", "WDG", "ERI", "ESC", "EUG", "ACV", "EUE", "EVV", "FAI", "FAR", "FMN", "FYV", "XNA", "FAY", "FLG", "FNT", "FLO", "MSL", "FNL", "QWF", "FOD", "FLL", "TBN", "RSW", "FSM", "VPS", "FWA", "DFW", "FKL", "FAT", "GNV", "GUP", "GCK", "GYY", "GCC", "GGG", "GGW", "GDV", "GLV", "GNU", "JGC", "GCN", "GFK", "GRI", "GJT", "GRR", "GPZ", "KGX", "GTF", "GRB", "GSO", "GLH", "PGV", "GSP", "GON", "GPT", "GUC", "GST", "HGR", "SUN", "HNS", "PHF", "HNM", "PAK", "CMX", "LEB", "HRL", "MDT", "HRO", "BDL", "HAE", "HVR", "HDN", "HYS", "HKB", "HLN", "AVL", "HIB", "HKY", "GSO", "ITO", "HHH", "HBB", "HYL", "HCR", "HOM", "HNL", "MKK", "HNH", "HPB", "HOT", "HOU", "HOU", "IAH", "HUS", "HTS", "HSV", "HON", "HSL", "HYA", "HYG", "IDA", "IGG", "ILI", "IPL", "IND", "INL", "IYK", "IMT", "IWD", "ISP", "ITH", "JAC", "JAN", "MKL", "JAX", "OAJ", "JMS", "JHW", "JVL", "BGM", "TRI", "JST", "JBR", "JLN", "JNU", "OGG", "KAE", "KNK", "AZO", "LUP", "KLG", "KAL", "MUE", "MCI", "JHM", "KXA", "KUK", "LIH", "EAR", "EEN", "ENA", "KTN", "EYW", "QKS", "IAN", "GGG", "ILE", "KVC", "AKN", "IGM", "TRI", "KPN", "IRK", "KVL", "LMT", "KLW", "TYS", "OBU", "ADQ", "KOA", "KKH", "KOT", "OTZ", "KYU", "KWT", "KWK", "LSE", "LAF", "LFT", "LCH", "HII", "LMA", "LNY", "LNS", "LAN", "LAR", "LRD", "LAS", "LBE", "PIB", "LAW", "LEB", "KLL", "LWB", "LWS", "LWT", "LEX", "LBL", "LIH", "LNK", "LIT", "LGB", "GGG", "LPS", "LAX", "SDF", "FNL", "QWF", "LBB", "MCN", "MSN", "MDJ", "MHT", "MHK", "MBL", "MKT", "MLY", "KMO", "PKB", "MWA", "MQT", "MLL", "MVY", "AOO", "MCW", "MSS", "OGG", "MFE", "MCK", "MCG", "MFR", "MYU", "MLB", "MEM", "MCE", "MEI", "MTM", "WMK", "MIA", "MPB", "MBS", "MAF", "MLS", "MKE", "MSP", "MOT", "MNT", "MFE", "MSO", "CNY", "MOB", "MOD", "MLI", "MLU", "MRY", "MGM", "MTJ", "MGW", "MWH", "WMH", "MOU", "MSL", "MKG", "MYR", "ACK", "WNA", "PKA", "APF", "BNA", "NKI", "NLG", "NCN", "HVN", "KGK", "GON", "MSY", "KNW", "NYC", "JFK", "LGA", "EWR", "SWF", "PHF", "WWT", "NME", "NIB", "IKO", "WTK", "OME", "NNL", "ORV", "OFK", "ORF", "OTH", "LBF", "ORT", "NUI", "NUL", "NUP", "OAK", "MAF", "OGS", "OKC", "OMA", "ONT", "SNA", "ORL", "MCO", "OSH", "OTM", "OWB", "OXR", "PAH", "PGA", "PSP", "PFN", "PKB", "PSC", "PDB", "PEC", "PLN", "PDT", "PNS", "PIA", "KPV", "PSG", "PHL", "TTN", "PHX", "PIR", "UGB", "PIP", "PQS", "PIT", "PTU", "PLB", "PIH", "KPB", "PHO", "PIZ", "PNC", "PSE", "PTA", "CLM", "BPT", "KPC", "PTH", "PML", "PPV", "PCA", "PWM", "PDX", "PSM", "POU", "PRC", "PQI", "BLF", "PVD", "PVC", "SCC", "PUB", "PUW", "UIN", "KWN", "RDU", "RMP", "RAP", "RDG", "RDV", "RDD", "RDM", "RNO", "RHI", "RIC", "RIW", "ROA", "RCE", "RST", "ROC", "RKS", "RFD", "RKD", "RSJ", "ROW", "RBY", "RSH", "RUT", "SMF", "MBS", "STC", "STG", "SGU", "STL", "KSM", "SMK", "SNP", "SLE", "SLN", "SBY", "SLC", "SJT", "SAT", "SAN", "SFO", "SJC", "SJU", "SBP", "SDP", "SFB", "SNA", "SBA", "SAF", "SMX", "STS", "SLK", "SRQ", "CIU", "SAV", "SVA", "SCM", "BFF", "AVP", "LKE", "SEA", "WLK", "SWD", "SHX", "SKK", "MSL", "SXP", "SHR", "SHH", "SHV", "SHG", "SVC", "SUX", "FSD", "SIT", "SGY", "SLQ", "SBN", "WSN", "SOP", "GSP", "GEG", "SPI", "SGF", "PIE", "SCE", "SHD", "SBS", "WBB", "CWA", "SVS", "SWF", "SCK", "SRV", "SUN", "SYR", "TCT", "TKA", "TLH", "TPA", "TAL", "TSM", "TEK", "KTS", "TEX", "TKE", "HUF", "TEH", "TXK", "TVF", "KTB", "TNC", "TOG", "TKJ", "OOK", "TOL", "FOE", "TVC", "TTN", "TUS", "TUL", "TLT", "WTL", "TNK", "TUP", "TCL", "TWF", "TWA", "TYR", "UNK", "CMI", "UCA", "UTO", "EGE", "QBF", "VDZ", "VLD", "VPS", "VEE", "OXR", "VEL", "VCT", "VIS", "ACT", "AIN", "WAA", "ALW", "WAS", "IAD", "DCA", "KWF", "ALO", "ART", "ATY", "CWA", "EAT", "PBI", "WYS", "HPN", "WST", "WSX", "WWP", "WMO", "LEB", "SPS", "ICT", "AVP", "PHF", "IPT", "ISN", "ILM", "BDL", "ORH", "WRL", "WRG", "YKM", "YAK", "COD", "YNG", "YUM", "YXX", "AKV", "XLY", "XFS", "YTF", "YAA", "YAX", "YAB", "YEK", "YAT", "YPJ", "YBG", "YBC", "YBK", "ZBF", "XBE", "ZEL", "QBC", "XVV", "YBV", "YTL", "YBI", "YBX", "YVB", "XPN", "YBR", "XFV", "YBT", "XBR", "YPZ", "YYC", "YCB", "YBL", "XAZ", "YTE", "XAW", "YRF", "XZB", "YCG", "YAC", "XCI", "XDL", "YLD", "YHG", "YYG", "XCM", "XHS", "YCS", "YHR", "YMT", "YKU", "ZUM", "XAD", "YYQ", "YCY", "XGJ", "YCK", "YQQ", "YZS", "YCC", "XGK", "YCA", "YXC", "YCR", "YDN", "YDI", "YDA", "YDQ", "YDF", "YVZ", "YWJ", "XDM", "YHD", "DUQ", "ZEM", "XZL", "YEG", "YPF", "YFO", "ZFD", "YFA", "YPY", "YAG", "YGH", "YFH", "YMM", "YYE", "YER", "YFS", "YSM", "YXJ", "YFX", "XFC", "YFC", "YQX", "XDD", "YGP", "XHM", "ZGS", "YGX", "YGB", "YHK", "XZC", "YGO", "ZGI", "YYR", "YQU", "XGY", "YGZ", "XIA", "XDG", "YHZ", "YUX", "YHM", "YGV", "YHY", "XDU", "YOJ", "YHI", "YHO", "ZHO", "YHB", "YGT", "YGR", "ILF", "XIB", "YPH", "YEV", "YFB", "YIV", "YIK", "XDH", "XJL", "XJQ", "YKA", "XGR", "YWB", "YKG", "YYU", "XKS", "ZKE", "KEW", "ZKG", "YLW", "YQK", "YLC", "KIF", "XEG", "YGK", "YKF", "YKT", "YBB", "YCO", "YVP", "YGW", "YGL", "YVC", "ZLT", "YLQ", "XLB", "XEE", "XEH", "XEJ", "YLH", "YLR", "YQL", "YLL", "XDQ", "YXU", "YSG", "YMH", "XID", "YXH", "XEK", "XEY", "XDP", "YQM", "YYY", "XAX", "YMY", "XLM", "YMQ", "YUL", "YMO", "MSA", "YDP", "YQN", "ZNA", "YCD", "YSR", "XIF", "YNA", "YNS", "XEL", "XEM", "XLV", "YUY", "YVQ", "YYB", "YNO", "YNE", "YOG", "YOC", "YBS", "YOO", "XDS", "YOW", "YOH", "YIF", "YXP", "XFE", "XPB", "YPC", "YPE", "YPO", "YTA", "YYF", "XFG", "YPL", "YPM", "XPX", "YNL", "YIO", "YHP", "YPB", "YZT", "YHA", "YPN", "YSO", "YPX", "YPW", "XII", "YPA", "XDV", "YXS", "XDW", "YPR", "XPK", "YVM", "XQU", "YQC", "YQB", "YFZ", "XLK", "XLJ", "XFY", "YQZ", "YRA", "YOP", "YRT", "YRL", "YRS", "YQR", "YUT", "YRB", "YRG", "YXK", "XRP", "YRJ", "ZRJ", "YUY", "ZPB", "YSY", "XKV", "XIM", "YSJ", "YYT", "YSL", "YZG", "ZSJ", "YSK", "XDX", "YZR", "YXE", "YAM", "YKL", "XFK", "YZV", "ZTM", "XFL", "XFM", "YXL", "YSH", "YYD", "YFJ", "XSI", "YAY", "YCM", "XIO", "YST", "YJT", "YSF", "XTY", "XDY", "YSB", "SUR", "ZJN", "YQY", "XTL", "YYH", "YTQ", "YXT", "ZTB", "XDZ", "YQD", "YTD", "YTH", "YQT", "YTS", "YAZ", "YBZ", "XLQ", "YTZ", "YYZ", "XLZ", "YUB", "ZFN", "YUD", "YBE", "YVO", "CXH", "XEA", "YVR", "YWH", "YYJ", "YWK", "YKQ", "XWA", "YWP", "YNC", "XFQ", "YLE", "YXN", "YWR", "YXY", "YWM", "YWL", "XEC", "YQG", "XEF", "YWG", "ZWL", "XIP", "WNN", "XWY", "YQI", "YZF", "ZAC", "AAL", "AES", "ZID", "AAR", "JEG", "ABD", "ABA", "ABZ", "AHB", "ABJ", "AUH", "ABS", "ABV", "ACA", "AGV", "ACC", "ADA", "ADD", "ADL", "ADE", "AER", "AZR", "AFT", "AGA", "IXA", "AUP", "AGF", "AGR", "AJI", "BQN", "AGU", "AGJ", "AMD", "AWZ", "AIM", "AEO", "AIC", "AIT", "AJL", "AJA", "AXT", "AKU", "AKX", "AEY", "AAN", "AAC", "AAY", "AHU", "ABT", "ABX", "ACI", "ALP", "ALJ", "ALY", "AXD", "FJR", "AHO", "ALG", "ALC", "ASP", "AKX", "LEI", "ARD", "AOR", "GUR", "ALF", "ATM", "AAT", "ACH", "ARR", "ASJ", "AZB", "IVA", "AMY", "WAM", "AMQ", "ASV", "AMV", "AMM", "ADJ", "ATQ", "AMS", "DYR", "HVA", "AAQ", "AOI", "ANX", "AZN", "AUY", "JHE", "ANE", "QXG", "AGD", "AQG", "ANG", "AXA", "AWD", "AKA", "ESB", "ANK", "JVA", "AAE", "NCY", "ANM", "AYT", "TNR", "ANU", "ANF", "WAQ", "DIE", "WAI", "ANR", "ZAY", "AOJ", "AOT", "APO", "APW", "FGI", "AQJ", "AJU", "ARU", "ARW", "ARP", "AUX", "AAG", "RAE", "AUC", "AMH", "ADU", "AQP", "AGH", "GYL", "ARI", "ARH", "AXM", "ARM", "ATC", "RUA", "AUA", "ARK", "AJR", "AKJ", "ASB", "ASM", "ASO", "ATZ", "TSE", "ASF", "OVD", "ASU", "ASW", "AXK", "ATH", "AIU", "ATD", "AUQ", "GUW", "AKL", "AGB", "AKS", "AUL", "IXU", "AUR", "AUU", "AVN", "AYW", "AYQ", "BXB", "BCD", "BJZ", "BXD", "BDD", "IXB", "BJR", "BHV", "BHI", "BFQ", "BSC", "BAH", "BAY", "VMU", "GYD", "BAS", "BZI", "BPN", "OPU", "BNK", "BBA", "BXR", "ABM", "BKO", "BTJ", "BND", "TKG", "BDH", "BWN", "BDO", "BLR", "BPX", "BKK", "BNX", "BDJ", "BJL", "BMV", "BNP", "BGF", "BSD", "BAV", "BCA", "BCI", "BCN", "BLA", "BDU", "BRI", "BNS", "BBN", "BZL", "BAX", "BRM", "BCL", "BRR", "EJA", "BAQ", "BRA", "BSO", "BSL", "ZDH", "BUZ", "BIA", "BTH", "BRT", "BHS", "BAL", "BLJ", "BXM", "BJF", "BBM", "BUS", "BPF", "BAU", "BYM", "BYU", "CBH", "BEU", "EIS", "BEI", "LAQ", "BHY", "PEK", "BEW", "BEY", "BJA", "BLG", "BEL", "BMY", "BFS", "BHD", "EGO", "BEG", "BZE", "TZA", "BNY", "BMD", "CNF", "PLU", "BEB", "BEN", "BKS", "BEJ", "BBO", "BGO", "EGC", "BVG", "BER", "TXL", "THF", "SXF", "BDA", "BRN", "ZDJ", "BPY", "BZR", "BDP", "BWA", "BMO", "BHR", "BHU", "BHO", "BBI", "BHJ", "BIK", "BIQ", "BII", "BIO", "BLL", "BMU", "BIM", "NSB", "BTU", "NTI", "BIR", "BVI", "BHX", "BHH", "FRU", "BSK", "OXB", "BKQ", "BLK", "BLT", "BQS", "BLZ", "BHE", "CNF", "BFN", "BVC", "BOV", "BVB", "BOC", "BOO", "BJV", "BOG", "GIC", "BJB", "BUI", "BWK", "BZO", "BOA", "BOM", "BON", "BNJ", "BOB", "BOD", "HBE", "BMK", "BLE", "RNN", "BOX", "BSA", "BQL", "BOJ", "BRK", "BOH", "BCQ", "BMP", "BSB", "BTS", "BTK", "BWE", "BZV", "BRE", "BES", "BWQ", "BGI", "BDS", "BNE", "BRS", "BVE", "BRQ", "ZDN", "BHQ", "BNN", "BME", "BHG", "BRU", "ZYR", "CRL", "BGA", "BBU", "OTP", "BUD", "AEP", "EZE", "UUA", "BJM", "BUA", "BHK", "BKZ", "BUQ", "UUA", "BDB", "BXZ", "BUO", "LEV", "BFV", "BUC", "BWT", "PUS", "BXU", "BZG", "SJD", "CFR", "CGY", "CAG", "CNS", "CAI", "CJA", "CBQ", "CJC", "CCU", "CLO", "CLY", "CMW", "CBG", "CRD", "CAL", "CPE", "CPV", "CPQ", "CGR", "CAW", "CAS", "CBR", "CUN", "CEQ", "JCA", "QYW", "CIW", "CAP", "CPI", "CPT", "CVL", "CCS", "CKS", "CCF", "CWL", "CVQ", "RIK", "CTG", "CUP", "CAS", "CMN", "CAC", "CSI", "CST", "DCM", "CTC", "CTA", "CAQ", "CXJ", "CAY", "CYB", "CYO", "CEB", "CED", "JCU", "ZBR", "CMF", "IXC", "CGQ", "CGD", "CHX", "CZX", "CHQ", "CHG", "XAP", "CTL", "CHT", "CSY", "CEK", "MAA", "CJJ", "CEE", "CTU", "CEG", "CTM", "CEE", "CMJ", "CNX", "CEI", "CYI", "CIX", "CIF", "CUU", "YAI", "CIP", "KIV", "HTA", "CJL", "CTD", "CGP", "CHY", "CKG", "CHC", "XCH", "ICI", "AVI", "CBL", "CME", "AGT", "CJS", "CEN", "CVM", "CFE", "CVC", "CNJ", "CMK", "CLJ", "CAZ", "CIJ", "CBB", "COK", "CNC", "CCK", "CUQ", "CFS", "CJB", "CLQ", "QKL", "CGN", "CMB", "ONX", "CKY", "CCP", "COC", "COG", "CND", "CZL", "OTD", "CPD", "CTN", "OOM", "CNB", "CPH", "CPO", "COR", "ORK", "CZE", "CZH", "CNQ", "CMG", "CVU", "CBO", "COC", "CXB", "CZM", "CCV", "CCM", "CKI", "CRI", "CRV", "CZS", "CUC", "CUE", "CVJ", "CGB", "CUL", "CUM", "CMA", "CUR", "CWB", "CUZ", "DAD", "DRH", "TAE", "DKR", "VIL", "DLM", "DLU", "DLC", "DAM", "DMM", "DGA", "DAR", "NLF", "DAU", "DRW", "DTD", "DVO", "DAV", "TVY", "DAX", "DYG", "DDI", "DOL", "DBM", "DBT", "DEZ", "DEL", "DEM", "DNM", "DNZ", "DPS", "DEA", "DSK", "DRB", "DER", "DSE", "DPO", "DAC", "DIB", "DIN", "DIJ", "DIL", "DLY", "DMU", "DNR", "DPL", "DIR", "DIU", "DIY", "DJG", "DJE", "JIB", "DNK", "DOB", "DOD", "DDM", "DOH", "DCF", "DOM", "CFN", "DOK", "DOG", "DMD", "DTM", "DOU", "DLA", "DRS", "XNB", "DXB", "DBO", "DUB", "DBV", "DGT", "DUM", "DND", "DUD", "DNH", "DKI", "DGO", "DUR", "DYU", "DUS", "MGL", "QDU", "DZA", "ELS", "EBO", "EOI", "EDI", "EDO", "EDR", "EGS", "EIN", "EIB", "SVX", "EHL", "ELF", "EMX", "EBD", "ELU", "EPS", "ELE", "ESR", "VIG", "EYP", "ETH", "EZS", "EBA", "ELC", "EDL", "ELH", "ESL", "EAE", "EMS", "EMD", "EMO", "EWI", "ENE", "ENT", "ENF", "ENH", "EBB", "ENU", "EPL", "ECN", "ERF", "ERC", "ERZ", "EBJ", "ZBB", "ESM", "EPR", "SON", "EQS", "EXT", "EWE", "EXM", "VDB", "FIE", "LYP", "FAJ", "FKQ", "FAV", "RVA", "FAO", "FAE", "FRE", "FEG", "FEN", "FEZ", "WFI", "FSC", "FZO", "XFW", "FIZ", "FLF", "FLR", "FLA", "FLW", "FRS", "FLN", "FRO", "FOG", "FDE", "FMA", "FTU", "FDF", "FOR", "FRC", "MVB", "FRW", "HHN", "FRA", "ZBJ", "FPO", "FNA", "FDH", "FUE", "FUK", "FUJ", "FKS", "FUN", "FNC", "FTA", "FUT", "FUG", "FOC", "GBE", "GAF", "GGN", "GPS", "GEV", "GWY", "GAX", "GMB", "GAN", "KAG", "GHE", "GAR", "GRL", "GPN", "GOV", "ELQ", "ZGU", "GAU", "GZA", "GZT", "GDN", "GEB", "GDZ", "EGN", "GES", "GVA", "GOA", "GGT", "GRJ", "GEO", "GET", "GRO", "LTD", "GHA", "GHT", "GIB", "GIL", "GIS", "GIZ", "GZO", "GLT", "GLA", "PIK", "GLI", "GOI", "GOB", "GGS", "GDE", "GYN", "OOL", "GLF", "GOQ", "GOE", "GDQ", "GOR", "GKA", "GTO", "GOT", "GSE", "GBL", "GUD", "GOV", "GHB", "GVR", "OYA", "GZM", "GRW", "GFN", "GRX", "GCM", "GDT", "GRZ", "GND", "GNB", "GFF", "GRY", "JGR", "GRQ", "GTE", "GDL", "GUM", "GJA", "BJX", "CAN", "GAO", "GUA", "GYE", "GYA", "GYM", "GCI", "GUB", "KWL", "GUI", "ULU", "KWE", "KUV", "URY", "GWD", "KWJ", "GWL", "KVD", "LWN", "HPA", "HAC", "HFS", "HFA", "HAK", "HAS", "HLD", "HPH", "HKD", "ZHQ", "HCQ", "HAD", "HAM", "LBC", "HTI", "BDA", "HLZ", "HFT", "HGH", "HAQ", "HAN", "HAJ", "HZG", "HRE", "HRB", "HGA", "EVE", "HME", "HAA", "HDY", "HTR", "HAU", "HAV", "HIS", "HFE", "HDB", "HGL", "HEL", "HEH", "HER", "HDF", "HMV", "HMO", "XAK", "HVB", "HIJ", "HIW", "HIT", "SGN", "HBA", "HOD", "HDS", "HOQ", "HOF", "HET", "HKK", "HOG", "HKG", "HIR", "HVG", "HOK", "HID", "HFN", "HOR", "HKN", "HTN", "HOE", "HUQ", "HUH", "HUN", "HHQ", "HUU", "HYN", "HUX", "HUV", "HUI", "HGD", "HLF", "HUY", "HRG", "HWN", "HYD", "IAS", "IBE", "IBZ", "IAA", "IGU", "IGR", "IHU", "ILP", "IOS", "ILA", "ILO", "IUL", "JAV", "IMP", "IMF", "IAM", "IGA", "INX", "IDN", "IDR", "INN", "INA", "IVC", "IVR", "INV", "IOA", "IOP", "IPN", "IPI", "IPE", "IPH", "IPA", "IQQ", "IQT", "IKT", "IFJ", "IFN", "ISG", "ISB", "YIV", "ILY", "IOM", "ISC", "TSO", "IST", "ITB", "ITK", "IVL", "IFO", "IWJ", "ZIH", "IZT", "ADB", "IZO", "JAT", "JCR", "JAG", "JAQ", "JAI", "CGK", "JAL", "UIT", "DJB", "JGA", "JKR", "JQE", "DJJ", "JED", "JEJ", "CJU", "XRY", "JER", "JSR", "JMU", "JGN", "GJL", "JIJ", "JIM", "TNA", "JDZ", "JHG", "JIN", "JJN", "HIN", "BCO", "JNZ", "JPR", "JIW", "JPA", "JDH", "JOE", "JNB", "JON", "JHB", "JOI", "IXJ", "JMO", "JKG", "JRH", "JSM", "AJF", "JDO", "JUI", "JDF", "JUJ", "JCK", "JUL", "JUZ", "JYV", "KDM", "KBT", "ABK", "KBL", "KBM", "KCF", "KDO", "KZF", "KAT", "KAJ", "KAX", "KGD", "KBX", "KAC", "KCD", "KUY", "KAN", "KHI", "KDL", "KAB", "FKB", "AOK", "KBF", "ZKB", "KAA", "BBK", "KTR", "KTM", "KTW", "KUN", "KVA", "KVG", "KAW", "ASR", "KZN", "EFL", "KDI", "CFU", "HJR", "UVL", "HRK", "LBD", "KDD", "IEV", "KBP", "KGL", "TKQ", "JRO", "YLC", "KIN", "KTP", "FIH", "IRA", "KTD", "KTT", "UNG", "KWY", "NOC", "KCZ", "USM", "CCU", "QJY", "KXK", "KYA", "ROR", "OSZ", "KBR", "BKI", "KWM", "CCJ", "KBV", "KRK", "KWG", "KUL", "TGG", "KUA", "KUG", "KCH", "KCM", "KUD", "AKF", "KUS", "UEO", "CMU", "KUO", "KUQ", "KUH", "KUT", "KAO", "KWI", "KWA", "KYZ", "LCE", "LCG", "PLP", "LPB", "LAP", "IRJ", "LRM", "LSC", "EUN", "LBS", "LAB", "LBJ", "LBU", "LML", "LAE", "LAJ", "LGQ", "ING", "LOS", "LDU", "LHE", "LKB", "LKL", "LLI", "LPM", "LNB", "SUF", "LPI", "LMP", "LAU", "LEQ", "LUV", "LGK", "LAI", "ACE", "LHW", "ZGC", "LAO", "LPP", "LKA", "LCA", "LRH", "LPA", "LSP", "LTK", "LUC", "LST", "LAD", "LVO", "LWY", "LEH", "ZLN", "LPY", "LTQ", "LEA", "LBA", "LGP", "IXL", "LER", "LEJ", "LKN", "LXS", "BJX", "LNO", "LET", "LXA", "LYG", "LIR", "LBV", "VXC", "LGG", "LIF", "LHG", "LNV", "LJG", "LIK", "LIL", "XDB", "LLW", "LIM", "LMN", "LIG", "LDC", "LDI", "LPI", "LYI", "LNZ", "LIS", "LSY", "LZH", "LPL", "LVI", "LZR", "LJU", "IRG", "LOF", "LOH", "LFW", "LON", "BQH", "LGW", "LHR", "LCY", "LTN", "STN", "LDY", "QQP", "LDB", "LPU", "LBP", "LBW", "HAP", "LGI", "LGL", "ODN", "LOD", "LRE", "LYR", "LNE", "LDH", "LTO", "LRT", "SJD", "LMM", "LSA", "LDE", "LZC", "LAD", "LXG", "LPQ", "LKO", "LUD", "LUG", "VSG", "LUA", "LLA", "FBM", "LYA", "LUN", "LUW", "LUX", "LUM", "LXR", "LZO", "LWO", "LYC", "LYS", "XYD", "MST", "UBB", "MCP", "XMS", "MFM", "MCZ", "MCH", "MKY", "MAG", "MED", "MAD", "IXM", "HGN", "MAQ", "MWF", "MFA", "GDX", "MQF", "VVB", "SEZ", "MXT", "MMO", "MJE", "MJN", "MAJ", "MQX", "MCX", "MKU", "MZG", "SSG", "MKZ", "AGP", "MAK", "LGS", "MLX", "MLE", "MYD", "MMX", "MAV", "PTF", "MLA", "WMP", "MNF", "MDC", "MGA", "WVK", "WMR", "NGX", "MNJ", "MAO", "MAN", "MDL", "WMA", "MGS", "IXE", "MAY", "MNR", "MFO", "XMH", "MHX", "MNL", "MNG", "MZL", "MJA", "MHG", "MKW", "MSE", "MEC", "MAS", "MZO", "ZLO", "MTS", "AMO", "MXS", "MPM", "MDQ", "MRE", "MAB", "MAR", "MYC", "MEE", "MGH", "MBX", "MHQ", "JSU", "MII", "MGF", "MPW", "WMN", "MVR", "MRS", "MHH", "MUR", "MBH", "MBT", "MSU", "MHD", "MAM", "AMI", "MMJ", "MYJ", "MUN", "MUK", "MNU", "MOF", "MUB", "MAU", "MRU", "MYG", "MAZ", "MZT", "MDK", "MJM", "MCV", "MES", "EOH", "MDE", "MKR", "MEH", "MXZ", "MJB", "MKS", "MEL", "MLN", "MMB", "NDM", "MDU", "MDZ", "MAH", "MYX", "MKQ", "MWE", "RDE", "MID", "MRD", "MIM", "MUH", "ETZ", "MXL", "MEX", "MFU", "ZVA", "MDS", "MDY", "MIK", "JMK", "BGY", "LIN", "MXP", "PMF", "MQL", "MIJ", "MGT", "MMD", "MTT", "MDP", "MRV", "MHP", "MSQ", "MYY", "MJZ", "MSJ", "MIS", "MRA", "MOI", "MYE", "MMY", "MTF", "MQN", "MOA", "MFJ", "ONI", "MNB", "MFF", "MGQ", "MJD", "MPK", "OKU", "MOL", "MBA", "MIR", "MBE", "LOV", "MJK", "MNY", "ROB", "MCM", "MEU", "MBJ", "MTR", "MTY", "MOC", "MVD", "MPL", "MNI", "MOZ", "MZI", "MXX", "TVA", "MXM", "MOV", "MRZ", "MLM", "HNA", "ONG", "MXH", "MOQ", "HAH", "MYA", "MOW", "BKA", "DME", "SVO", "VKO", "MJF", "OMO", "MTV", "MJL", "MON", "MGB", "HGU", "MHU", "ISA", "WME", "MMG", "MPN", "MPA", "MYW", "MVS", "MDG", "DGE", "FMO", "MKM", "MLH", "LII", "MUX", "MZV", "BOM", "MUA", "MUC", "MJV", "MMK", "MYI", "MSR", "MCT", "MUZ", "MFG", "MWZ", "MGZ", "MYT", "MJT", "ZZU", "NBX", "MNC", "NDR", "NAN", "NYM", "WNP", "NGS", "NGO", "NGO", "NAG", "NBO", "WIL", "NAJ", "NAK", "NST", "NAL", "NMA", "ATN", "NDK", "APL", "OSY", "NDI", "NNT", "NAO", "NKG", "NNG", "JNN", "NTE", "QJZ", "NTG", "NNY", "NYK", "NPE", "NAP", "NAW", "NAA", "JNS", "UAK", "NVK", "NNM", "NAS", "MAT", "NAT", "INU", "NVT", "WNS", "NUX", "NLA", "CNP", "NFG", "EGL", "NEG", "NVA", "EAM", "NSN", "NLP", "EMN", "NER", "NQN", "NEV", "GON", "NPL", "BEO", "NTL", "NCL", "ZNE", "NQY", "NGE", "NGI", "RPM", "NHA", "NIM", "NCE", "NIC", "FNI", "NGB", "NIX", "NFO", "NTT", "IUE", "NJC", "GOJ", "NOJ", "NDJ", "NRD", "NDZ", "NLK", "NSK", "NTN", "NRK", "NUS", "NCA", "ELH", "NRL", "NWI", "NOB", "NOS", "EMA", "NDB", "NKC", "NOU", "GEA", "NVR", "NOZ", "OVB", "GER", "NLD", "NHV", "TBU", "NCU", "NUB", "NNX", "ZAQ", "NUE", "GOH", "UYL", "NYU", "NYN", "OAX", "OBD", "OBO", "OCJ", "ZBQ", "ODS", "OHD", "OIT", "OKQ", "OKJ", "OHO", "OKA", "OIR", "OKL", "OLB", "OLJ", "OLP", "OMB", "OMS", "OND", "OMR", "ORN", "OAG", "OMD", "ORB", "REN", "ORW", "OER", "OSW", "HOV", "OSA", "ITM", "KIX", "OIM", "OSI", "OSK", "OSL", "TRF", "OSD", "OSR", "OTU", "OUA", "OGX", "OZZ", "ODY", "OUD", "OUL", "UVE", "VDA", "OYE", "PBJ", "JFR", "PDG", "PAD", "PPG", "PKZ", "PAF", "PCH", "PKY", "PLQ", "PLM", "PQM", "PMO", "PMI", "PMZ", "PMW", "PMR", "PLW", "PNA", "PTY", "PAC", "PKN", "PGK", "PJG", "PNL", "PPW", "PPT", "PFO", "PAJ", "PBO", "PID", "PBM", "ORG", "PRA", "PRS", "PAR", "CDG", "ORY", "BVA", "PMF", "PHB", "PBH", "PSI", "AOL", "PFB", "PSO", "PAT", "GPA", "PUF", "PWQ", "PEX", "PKU", "PET", "POL", "PMA", "PEN", "PYE", "PZE", "PEI", "PGX", "PMQ", "PEE", "PGF", "PER", "PEG", "PSR", "PEW", "PNZ", "PKC", "PES", "PHW", "PHS", "PNH", "PRH", "PQC", "HKT", "PIX", "PDS", "PZB", "PTG", "PIF", "PSA", "THU", "PIU", "PLJ", "PXU", "PBZ", "PLH", "TGD", "PNI", "PNR", "PTP", "PIS", "XOP", "PKR", "PLV", "PYJ", "PSE", "PDL", "PMG", "PNK", "PNP", "TAT", "PBD", "POR", "PMV", "POT", "PAP", "PUG", "WPB", "IXZ", "PLZ", "POG", "PHC", "PHE", "PLO", "PQQ", "POM", "POS", "PSY", "PZU", "VLI", "PTJ", "POA", "PXO", "BPS", "PVH", "OPO", "PVO", "PSS", "PAZ", "POZ", "PRG", "RAI", "PRQ", "PPB", "PVK", "PRN", "PPP", "PLS", "PCL", "PBC", "PYH", "PBE", "FUE", "PUD", "PXM", "PJM", "PEU", "PMY", "PEM", "PMC", "PZO", "POP", "PPS", "PSZ", "PVR", "PUY", "PNQ", "PUQ", "PUJ", "PDP", "PND", "PBP", "PUT", "PSU", "FNJ", "AQI", "JJU", "IQM", "TAO", "NDG", "ZQN", "UEL", "XQP", "QRO", "UET", "UIH", "UIB", "UIP", "ULP", "UIO", "RBP", "RBA", "RAB", "VKG", "RAT", "RAH", "RJN", "RFP", "RAJ", "RJH", "RBV", "RAM", "IXR", "UNN", "RAR", "RKT", "RAS", "RBE", "RAZ", "RBJ", "REC", "RCQ", "REG", "RNL", "RNS", "RES", "REU", "KEF", "REX", "RHO", "RAO", "RIB", "RCB", "RCM", "RIX", "RJK", "RMI", "RBR", "RCU", "GIG", "RGL", "RIG", "RGA", "ROY", "RVD", "RCH", "RIS", "RUH", "RIY", "RNE", "RTB", "VKG", "RSD", "ROK", "RDZ", "RRG", "RVK", "ZXM", "RMA", "ROM", "CIA", "FCO", "RNP", "RNB", "RRS", "RUR", "ROS", "RPN", "RET", "RLG", "ROV", "ROP", "ROT", "RTM", "URO", "RVN", "SZT", "QFZ", "STX", "SLU", "SXM", "LED", "STT", "LTT", "XPZ", "SPN", "SNO", "SLY", "SLX", "SLW", "SSA", "SZG", "KUF", "SVB", "UAS", "SMI", "ADZ", "OES", "SVZ", "BRC", "SJO", "SYQ", "SJU", "UAQ", "ULA", "SLP", "LUQ", "SAI", "CPC", "NMG", "SAP", "AFA", "ZSA", "SAL", "EAS", "SAH", "NDY", "NNB", "STB", "SPC", "VVI", "RIA", "SMA", "SMR", "RSA", "STM", "SMS", "SCL", "STI", "GEL", "NTO", "HEX", "SDQ", "STD", "SYX", "SNE", "CGH", "VCP", "GRU", "TMS", "VXE", "CTS", "OKD", "SSR", "RTW", "ZRM", "SUJ", "SWG", "SLZ", "SXK", "ZVK", "SVL", "SVU", "ZBY", "EGM", "GXF", "QFK", "SRG", "ZEG", "SEL", "GMP", "ICN", "ZRI", "SZM", "SVQ", "PVG", "SNN", "SWA", "SSH", "SZD", "SZX", "LWK", "LSI", "HIL", "CIT", "SYZ", "SYO", "JHQ", "REP", "IXS", "SYM", "NKD", "SIN", "XSP", "SQG", "JHS", "AKY", "VAS", "JSI", "SKP", "KVB", "SZK", "SXL", "DWB", "SOO", "SOF", "SOG", "SOC", "SQH", "SOJ", "SOD", "TZN", "XSC", "SOU", "SOI", "SPU", "AXP", "SXR", "STX", "RUN", "SKB", "FSP", "SVD", "EBU", "EUX", "UVF", "UVF", "LED", "ZSE", "STT", "STW", "SVG", "SML", "STO", "ARN", "BMA", "SYY", "SQO", "XER", "SXB", "SOY", "TNX", "STR", "ZWS", "VAO", "SRE", "SYU", "SUL", "THS", "NTY", "MCY", "SUB", "URT", "SUV", "EVG", "SVJ", "SYD", "ZYL", "SZZ", "TCP", "TBJ", "TBT", "TBO", "TBZ", "TBG", "TUU", "TCG", "THL", "TAC", "TCQ", "TXG", "TIF", "TNN", "TSA", "TPE", "TTT", "TYN", "TAI", "TLL", "TMR", "TNO", "TMM", "WTA", "TMC", "TMU", "TMP", "TAM", "TMW", "TMH", "TNG", "TJQ", "TJS", "TAH", "TAP", "TRK", "TRA", "TAR", "TPP", "TRW", "TRO", "TIZ", "TJA", "TAS", "TUO", "TRG", "TVU", "TWU", "TEE", "TBS", "TCH", "TEU", "MME", "TFF", "TGU", "THR", "TKB", "TLV", "TIM", "TXM", "ZCO", "TFN", "TFS", "TCA", "TPQ", "TER", "THE", "TMJ", "TTE", "TDB", "TET", "TTU", "TEZ", "SNW", "THG", "XTG", "TBI", "SKG", "JTR", "TRV", "THO", "TIS", "TSN", "TID", "TGJ", "TIJ", "TIH", "IKS", "TIU", "TMX", "TSR", "TIN", "TIQ", "TIY", "TOD", "TIE", "TIA", "TRE", "TGM", "TRZ", "TIR", "TIV", "TLM", "TAB", "TOB", "TKN", "TKS", "TYO", "HND", "NRT", "TOW", "TLC", "TPR", "TMG", "TOM", "TOF", "TGO", "TGH", "TWB", "TRC", "TOH", "TYF", "TOV", "TTB", "TTQ", "TTJ", "TOU", "TLN", "TLS", "TUF", "XSH", "TSV", "TOY", "TOE", "TZX", "TST", "TPS", "TGN", "TCB", "REL", "TRS", "TDD", "POS", "TIP", "THN", "TMT", "TOS", "TRD", "TJI", "TRU", "TKK", "TTS", "WTS", "TSB", "TSJ", "TUB", "TUC", "TUV", "TUR", "TFI", "TUG", "TUA", "TLE", "TUJ", "TCO", "TBP", "TUN", "TXN", "TUI", "TUK", "TRN", "TKU", "TGZ", "TJM", "UBJ", "UBA", "UDI", "UBP", "UDR", "UTH", "UFA", "UJE", "UPG", "UCT", "ULN", "HLH", "UUD", "ULB", "ULY", "ULI", "USN", "ULD", "UME", "UTT", "JUV", "UTN", "URJ", "URA", "UGC", "OMH", "URU", "UPN", "URG", "URC", "USL", "USH", "USK", "UKK", "UIK", "UTP", "UII", "UTK", "UMD", "UDJ", "VAA", "BDQ", "VDS", "ZAL", "VLC", "VLN", "XVS", "VLV", "VLS", "VLL", "VUP", "VDE", "VAN", "YVR", "VAI", "VBV", "VNS", "VAW", "VAG", "VRK", "VAR", "VST", "VAT", "VAV", "VXO", "ANU", "VCE", "TSF", "VER", "VRA", "VRN", "VEY", "VFA", "VCD", "VDM", "VIE", "VTE", "VQS", "VGO", "VNX", "VHM", "BVH", "VLG", "VME", "VSA", "VNO", "VII", "VIJ", "VBY", "VTZ", "VTB", "VDC", "VIT", "VIV", "OGZ", "VVO", "VOH", "VLK", "VOG", "VPN", "VKT", "VOZ", "WAE", "WHF", "WET", "WGA", "WBA", "WGP", "WKJ", "WLH", "WGE", "WLS", "WVB", "WMX", "WKA", "WAG", "AGE", "AGL", "WXN", "WAW", "WSR", "WSU", "WAT", "WUG", "WUU", "WED", "EJH", "WEH", "WEI", "WLG", "WNZ", "GWT", "WSZ", "WRY", "WWK", "WHK", "WRE", "WYA", "WIC", "WVN", "WUN", "WNR", "WIN", "WJA", "WOT", "WJU", "WTO", "WTE", "WRO", "WUD", "WUH", "WUS", "WYN", "XMN", "XIY", "XFN", "XIC", "XKH", "XIL", "XNN", "XUZ", "YKS", "KYX", "XMY", "GAJ", "ENY", "YNB", "YNZ", "XYA", "RGN", "YNJ", "YNT", "YAO", "YAP", "IAR", "AZD", "EYL", "RSU", "EVN", "YBP", "YIH", "INC", "YIN", "YIW", "JOG", "YGJ", "OGN", "OKR", "RNJ", "UYN", "UUS", "ZAD", "ZAG", "ZAH", "ZTH", "ZAM", "ZNZ", "OZH", "ZAZ", "ZHA", "ZAT", "CGO", "PZH", "HSN", "ZUH", "IEG", "ZIH", "OUZ", "UGU", "ZRH"]
  end
  def valid_airport(airport)
    codes = airport_codes
    return codes.include?(airport.upcase)
  end
  def autocomplete_for_airport
    codes = airport_codes
    re = Regexp.new("^#{params[:query]}", "i")
    @airports = codes.select { |airport| airport.match re }
    render :json => {:query => params[:query], :suggestions => @airports, :data => @airports}.to_json
  end
  def old_flight_query
    if params[:flight] and params[:flight][:number].to_s!=""
      flight_date = Date.parse(params[:flight][:date]) 
      flight = Flight.find_or_create_by_flight_name_and_flight_date(params[:flight][:number],flight_date)
      flight.flight_date = flight_date
      flight.airport_code = params[:flight][:airport_code]
      result = bing_query(params[:flight][:number])
      if result["SearchResponse"]["InstantAnswer"]
        flight.airline_code = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["AirlineCode"]
        flight.airline_name = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["AirlineName"]      
        flight.flight_number = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["FlightNumber"]      
        flight.scheduled_departure = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["ScheduledDeparture"]      
        flight.scheduled_arrival = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["ScheduledArrival"]      
        flight.origin_airport_code = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["OriginAirport"]["Code"]      
        flight.origin_airport_name = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["OriginAirport"]["Name"]
        flight.origin_airport_tz = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["OriginAirport"]["TimeZoneOffset"]
        flight.destination_airport_code = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["DestinationAirport"]["Code"]      
        flight.destination_airport_name = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["DestinationAirport"]["Name"]
        flight.destination_airport_tz = result["SearchResponse"]["InstantAnswer"]["Results"][0]["InstantAnswerSpecificData"]["FlightStatus"]["DestinationAirport"]["TimeZoneOffset"]
      end
      flight.save
      redirect_to :controller => :ticket, :action => :flight, :id => flight.id
    else
      flash[:error] = "Please enter flight information."
      redirect_to :action => :index
    end
  end
end
