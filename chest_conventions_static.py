import inspect


class Enum(object):
    @classmethod
    def elems_as_list(cls):
        """ Get a list of tuples (string, int) with all the elements
        Returns
        -------
        List of tuples (string, int)
        """
        return [i for i in inspect.getmembers(cls) if isinstance(i[1], int)]

    @classmethod
    def elems_as_dictionary(cls, key_is_integer=True):
        """  Return a dictionary with all the elems in the enum class
        Parameters
        ----------
        key_is_integer: if True, the key of the dictionary is the integer value. Otherwise, the key will be the string representation

        Examples
        -------
        ChestRegion.get_elems(key_is_integer=True) = {0:'UNDEFINEDREGION', 1:'WHOLELUNG', ... }
        ChestRegion.get_elems(key_is_integer=False) = {'UNDEFINEDREGION':0, 'WHOLELUNG':1, ... }

        Returns
        -------
        Dictionary with the values (see examples)
        """
        # Get just the "enum" elements of the class
        all_members = cls.elems_as_list()

        if key_is_integer:
            # dictionary int->string
            key = 1
            value = 0
        else:
            # dictionary string->int
            key = 0
            value = 1

        result = {}
        for elem in all_members:
            result[elem[key]] = elem[value]
        return result

    @classmethod
    def number_of_elems(cls):
        """ Get the total number of element in the class
        Returns
        -------
        int
        """
        return len(cls.elems_as_list())


#############################
# ENUMERATIONS
#############################
class ChestRegion(Enum):
    """Populated automatically from /Resources/ChestConventions.xml file"""
    UNDEFINEDREGION = 0
    WHOLELUNG = 1
    RIGHTLUNG = 2
    LEFTLUNG = 3
    RIGHTSUPERIORLOBE = 4
    RIGHTMIDDLELOBE = 5
    RIGHTINFERIORLOBE = 6
    LEFTSUPERIORLOBE = 7
    LEFTINFERIORLOBE = 8
    LEFTUPPERTHIRD = 9
    LEFTMIDDLETHIRD = 10
    LEFTLOWERTHIRD = 11
    RIGHTUPPERTHIRD = 12
    RIGHTMIDDLETHIRD = 13
    RIGHTLOWERTHIRD = 14
    MEDIASTINUM = 15
    WHOLEHEART = 16
    AORTA = 17
    PULMONARYARTERY = 18
    PULMONARYVEIN = 19
    UPPERTHIRD = 20
    MIDDLETHIRD = 21
    LOWERTHIRD = 22
    LEFT = 23
    RIGHT = 24
    LIVER = 25
    SPLEEN = 26
    ABDOMEN = 27
    PARAVERTEBRAL = 28
    OUTSIDELUNG = 29
    OUTSIDEBODY = 30
    SKELETON = 31
    STERNUM = 32
    HUMERI = 33
    LEFTHUMERUS = 34
    RIGHTHUMERUS = 35
    SCAPULAE = 36
    LEFTSCAPULA = 37
    RIGHTSCAPULA = 38
    HILA = 39
    LEFTHILUM = 40
    RIGHTHILUM = 41
    KIDNEYS = 42
    LEFTKIDNEY = 43
    RIGHTKIDNEY = 44
    ASCENDINGAORTA = 45
    TRANSVERSALAORTA = 46
    DESCENDINGAORTA = 47
    LEFTSUBCLAVIAN = 48
    RIGHTSUBCLAVIAN = 49
    LEFTCORONARYARTERY = 50
    SPINE = 51
    LEFTVENTRICLE = 52
    RIGHTVENTRICLE = 53
    LEFTATRIUM = 54
    RIGHTATRIUM = 55
    LEFTPECTORALIS = 56
    RIGHTPECTORALIS = 57
    TRACHEA2 = 58
    LEFTMAINBRONCHUS = 59
    RIGHTMAINBRONCHUS = 60
    ESOPHAGUS = 61
    LEFTCHESTWALL = 62
    RIGHTCHESTWALL = 63
    LEFTDIAPHRAGM = 64
    RIGHTDIAPHRAGM = 65
    HIATUS = 66
    PECTORALIS = 67
    SPINALCORD = 68
    SUPERIORMESENTERICARTERY = 69
    PANCREAS = 70
    PANCREASHEAD = 71
    LEFTANTERIORCHESTWALL = 72
    RIGHTANTERIORCHESTWALL = 73
    LEFTPOSTERIORCHESTWALL = 74
    RIGHTPOSTERIORCHESTWALL = 75
    TRACHEACARINA = 76
    AORTICVALVE = 77
    VENACAVA = 78


class ChestType(Enum):
    """Populated automatically from /Resources/ChestConventions.xml file"""
    UNDEFINEDTYPE = 0
    NORMALPARENCHYMA = 1
    AIRWAY = 2
    VESSEL = 3
    EMPHYSEMATOUS = 4
    GROUNDGLASS = 5
    RETICULAR = 6
    NODULAR = 7
    OBLIQUEFISSURE = 8
    HORIZONTALFISSURE = 9
    MILDPARASEPTALEMPHYSEMA = 10
    MODERATEPARASEPTALEMPHYSEMA = 11
    SEVEREPARASEPTALEMPHYSEMA = 12
    MILDBULLA = 13
    MODERATEBULLA = 14
    SEVEREBULLA = 15
    MILDCENTRILOBULAREMPHYSEMA = 16
    MODERATECENTRILOBULAREMPHYSEMA = 17
    SEVERECENTRILOBULAREMPHYSEMA = 18
    MILDPANLOBULAREMPHYSEMA = 19
    MODERATEPANLOBULAREMPHYSEMA = 20
    SEVEREPANLOBULAREMPHYSEMA = 21
    AIRWAYWALLTHICKENING = 22
    AIRWAYCYLINDRICALDILATION = 23
    VARICOSEBRONCHIECTASIS = 24
    CYSTICBRONCHIECTASIS = 25
    CENTRILOBULARNODULE = 26
    MOSAICING = 27
    EXPIRATORYMALACIA = 28
    SABERSHEATH = 29
    OUTPOUCHING = 30
    MUCOIDMATERIAL = 31
    PATCHYGASTRAPPING = 32
    DIFFUSEGASTRAPPING = 33
    LINEARSCAR = 34
    CYST = 35
    ATELECTASIS = 36
    HONEYCOMBING = 37
    TRACHEA = 38
    MAINBRONCHUS = 39
    UPPERLOBEBRONCHUS = 40
    AIRWAYGENERATION3 = 41
    AIRWAYGENERATION4 = 42
    AIRWAYGENERATION5 = 43
    AIRWAYGENERATION6 = 44
    AIRWAYGENERATION7 = 45
    AIRWAYGENERATION8 = 46
    AIRWAYGENERATION9 = 47
    AIRWAYGENERATION10 = 48
    CALCIFICATION = 49
    ARTERY = 50
    VEIN = 51
    PECTORALISMINOR = 52
    PECTORALISMAJOR = 53
    ANTERIORSCALENE = 54
    FISSURE = 55
    VESSELGENERATION0 = 56
    VESSELGENERATION1 = 57
    VESSELGENERATION2 = 58
    VESSELGENERATION3 = 59
    VESSELGENERATION4 = 60
    VESSELGENERATION5 = 61
    VESSELGENERATION6 = 62
    VESSELGENERATION7 = 63
    VESSELGENERATION8 = 64
    VESSELGENERATION9 = 65
    VESSELGENERATION10 = 66
    PARASEPTALEMPHYSEMA = 67
    CENTRILOBULAREMPHYSEMA = 68
    PANLOBULAREMPHYSEMA = 69
    SUBCUTANEOUSFAT = 70
    VISCERALFAT = 71
    INTERMEDIATEBRONCHUS = 72
    LOWERLOBEBRONCHUS = 73
    SUPERIORDIVISIONBRONCHUS = 74
    LINGULARBRONCHUS = 75
    MIDDLELOBEBRONCHUS = 76
    BRONCHIECTATICAIRWAY = 77
    NONBRONCHIECTATICAIRWAY = 78
    AMBIGUOUSBRONCHIECTATICAIRWAY = 79
    MUSCLE = 80
    HERNIA = 81
    BONEMARROW = 82
    BONE = 83
    INTERSTITIALLUNGDISEASE = 84
    SUBPLEURALLINE = 85
    NODULE = 86
    BENIGNNODULE = 87
    MALIGNANTNODULE = 88
    SEPTUM = 89
    FIBRONODULAR = 90
    MESOTHELIOMA = 91
    NORMALINFLAMED = 92
    NORMALNOTINFLAMED = 93
    SYSTOLE = 94
    DIASTOLE = 95
    INJUREDPARENCHYMA = 96
    LUMEN = 97
    WALL = 98
    AIRWAYBRANCH = 99
    VESSELBRANCH = 100
    LYMPHNODE = 101


class ImageFeature(Enum):
    """Populated automatically from /Resources/ChestConventions.xml file"""
    UNDEFINEDFEATURE = 0
    CTARTIFACT = 1
    CTBEAMHARDENING = 2
    CTSTREAKARTIFACT = 3
    CTMOTION = 4
    CTCARDIACMOTION = 5
    CTBREATHINGMOTION = 6



class ReturnCode(Enum):
    """Populated automatically from /Resources/ChestConventions.xml file"""
    EXITSUCCESS = 0
    HELP = 1
    EXITFAILURE = 2
    RESAMPLEFAILURE = 3
    NRRDREADFAILURE = 4
    NRRDWRITEFAILURE = 5
    DICOMREADFAILURE = 6
    ATLASREADFAILURE = 7
    LABELMAPWRITEFAILURE = 8
    LABELMAPREADFAILURE = 9
    ARGUMENTPARSINGERROR = 10
    ATLASREGISTRATIONFAILURE = 11
    QUALITYCONTROLIMAGEWRITEFAILURE = 12
    INSUFFICIENTDATAFAILURE = 13
    GENERATEDISTANCEMAPFAILURE = 14
    SEGMENTATIONFAILURE = 15



class Plane(Enum):
    """Populated automatically from /Resources/ChestConventions.xml file"""
    UNDEFINEDPLANE = 0
    SAGITTAL = 1
    CORONAL = 2
    AXIAL = 3
